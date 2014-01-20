require "ans/resque/scheduler/web/version"

module Ans
  module Resque
    module Scheduler
      module Web
        autoload :Server, "ans/resque/scheduler/web/server"

        include ActiveSupport::Configurable

        configure do |config|
          config.schedules = {}
        end
      end
    end
  end
end
