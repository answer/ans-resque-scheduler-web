require "resque/server"

module Ans::Resque::Scheduler::Web::Server
  def self.included(base)
    base.class_eval do
      helpers do
        # ResqueScheduler's view helpers
        def format_time(t)
          t.strftime("%Y-%m-%d %H:%M:%S %z")
        end

        def queue_from_class_name(class_name)
          Resque.queue_from_class(ResqueScheduler::Util.constantize(class_name))
        rescue
          "<CLASS NOT FOUND>"
        end

        def part_configs(name)
          all_configs.map{|key,config|
            if config && hash = config[name]
              time_hash = {}
              %w(cron every).each do |key|
                if hash[key]
                  time_hash[key] = hash[key]
                end
              end
              unless time_hash.size > 0
                time_hash = nil
              end
            end
            [key,time_hash]
          }
        end
        def all_configs
          @all_configs ||= Ans::Resque::Scheduler::Web.config.schedules.map{|key,file|
            if FileTest.exist?(file)
              hash = YAML.load_file(file) rescue nil
              unless hash.respond_to?(:[])
                hash = nil
              end
              [key,hash]
            end
          }.compact
        end
        def all_schedule_interval(name)
          case name
          when Hash
            part_configs = name
          else
            part_configs = part_configs(name)
          end
          '<table style="margin:0;">' << part_configs.map{|key,config|
            "<tr><td>#{key}</td><td>#{h schedule_interval(config || {})}</td></tr>"
          }.join("") << "</table>"
        end

        def schedule_interval(config)
          if config['every']
            schedule_interval_every(config['every'])
          elsif config['cron']
            'cron: ' + config['cron'].to_s
          else
            'Not currently scheduled'
          end
        end

        def schedule_interval_every(every)
          s = 'every: '
          if every.respond_to?(:first)
            s << every.first
          else
            s << every
          end

          return s unless every.respond_to?(:length) && every.length > 1

          s << ' ('
          meta = every.last.map do |key, value|
            "#{key.to_s.gsub(/_/, ' ')} #{value}"
          end
          s << meta.join(', ') << ')'
        end

        def schedule_class(config)
          if config['class'].nil? && !config['custom_job_class'].nil?
            config['custom_job_class']
          else
            config['class']
          end
        end
      end

      get "/all-schedule" do
        Resque.reload_schedule! if Resque::Scheduler.dynamic
        erb File.read(File.join(File.dirname(__FILE__), 'server/views/schedule.erb'))
      end

      post "/all-schedule" do
        id = params["id"] || params[:id]
        if id.blank?
          erb File.read(File.join(File.dirname(__FILE__), 'server/views/schedule.erb'))
        else
          redirect u("/all-schedule/#{id}")
        end
      end

      get "/all-schedule/:id" do
        @name = params["id"] || params[:id]
        @config_hash = Resque.get_schedule(@name)
        if @config_hash
          @current_config_hash = @config_hash
        else
          description = ResqueScheduler::Util.constantize(@name).instance_variable_get(:@description) rescue @name
          @config_hash = {
            "description" => description,
            "class" => @name,
          }
        end
        @config = @config_hash.to_yaml

        erb File.read(File.join(File.dirname(__FILE__), 'server/views/edit.erb'))
      end
      post "/all-schedule/:id/confirm" do
        @name = params["id"] || params[:id]
        if params["reset"] || params[:reset]
          redirect u("/all-schedule/#{@name}")
        else
          @confirm = true
          if params["remove"] || params[:remove]
            @config = ""
          else
            @config = params["config"] || params[:config]
          end

          @config_hash = YAML.load(@config) rescue nil
          @current_config_hash = Resque.get_schedule(@name)

          @part_configs = params["part_config"] || params[:part_config]
          @part_config_hashes = Hash[@part_configs.map{|key,config|
            unless config.blank?
              hash = YAML.load(config) rescue nil
            end
            [key,hash]
          }]

          is_schedule_changed = false
          if params["commit"] || params[:commit]
            Ans::Resque::Scheduler::Web.config.schedules.map{|key,file|
              if FileTest.exist?(file)
                @current_key = key if file.start_with?(Rails.root.to_s)

                is_changed = false
                hash = YAML.load_file(file) rescue nil
                unless hash.respond_to?(:[])
                  hash = {}
                end
                if @config.blank?
                  hash.delete @name
                  is_changed = true
                else
                  if @config_hash.respond_to?(:[])
                    hash[@name] = @config_hash.merge(@part_config_hashes[key.to_s] || {})
                    is_changed = true
                  end
                end

                if is_changed
                  is_schedule_changed = true
                  if hash.size > 0
                    yaml = hash.to_yaml
                  end
                  File.open file, "w" do |f|
                    f.puts yaml
                  end
                  File.open "#{file}.reload", "w" do |f|
                    f.puts yaml
                  end
                end
              end
            }
          end

          if is_schedule_changed
            if @current_key
              Resque.schedule = YAML.load_file Ans::Resque::Scheduler::Web.config.schedules[@current_key]
            end
            redirect u("/all-schedule")
          else
            erb File.read(File.join(File.dirname(__FILE__), 'server/views/edit.erb'))
          end
        end
      end

    end
  end
end

Resque::Server.tabs << 'All-Schedule'

Resque::Server.class_eval do
  include Ans::Resque::Scheduler::Web::Server
end
