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

      get "/edit-schedule" do
        erb File.read(File.join(File.dirname(__FILE__), 'server/views/search.erb'))
      end
      post "/edit-schedule" do
        id = params["id"] || params[:id]
        if id.blank?
          erb File.read(File.join(File.dirname(__FILE__), 'server/views/search.erb'))
        else
          redirect u("/schedule/#{id}")
        end
      end

      get "/schedule/:id" do
        @name = params["id"] || params[:id]
        @current_config_hash = @config_hash = Resque.get_schedule(@name)
        if @config_hash.blank?
          @config = ""
        else
          @config = @config_hash.to_yaml
        end
        erb File.read(File.join(File.dirname(__FILE__), 'server/views/edit.erb'))
      end
      post "/schedule/:id/confirm" do
        @name = params["id"] || params[:id]
        @current_config_hash = Resque.get_schedule(@name)
        if params["reset"] || params[:reset]
          if @current_config_hash
            @config = @current_config_hash.to_yaml
          else
            @config = ""
          end
        else
          @confirm = true
          @config = params["config"] || params[:config]
        end

        require "psych"
        require "yaml"
        YAML::ENGINE.yamler = "psych"
        @config_hash = YAML.load(@config)
        if @config_hash.respond_to?(:[])
          @config_hash["class"] ||= @name
        end

        is_change_schedule = false
        if params["commit"] || params[:commit]
          if @config.blank?
            Resque.remove_schedule @name
            is_change_schedule = true
          else
            if @config_hash.respond_to?(:[])
              Resque.set_schedule @name, @config_hash
              is_change_schedule = true
            end
          end
        end

        if is_add_schedule
          File.open Rails.root.join("config/resque/schedule.yml"), "w" do |f|
            f.puts Resque.get_schedules.to_yaml
          end
          redirect u("/schedule")
        else
          erb File.read(File.join(File.dirname(__FILE__), 'server/views/edit.erb'))
        end
      end

    end
  end
end

Resque::Server.tabs << 'Edit-Schedule'

Resque::Server.class_eval do
  include Ans::Resque::Scheduler::Web::Server
end
