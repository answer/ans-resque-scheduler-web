require "ans/resque/scheduler/web/version"

module Ans
  module Resque
    module Scheduler
      module Web
        autoload :Server, "ans/resque/scheduler/web/server"

        include ActiveSupport::Configurable

        configure do |config|
          config.schedules = {}
          config.root = Rails.root.to_s
        end
      end
    end
  end
end
