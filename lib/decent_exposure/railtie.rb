require 'decent_exposure/default_exposure'
require 'decent_exposure/default_exposure_finder'

module DecentExposure
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer "decent_exposure.extend_action_controller_base" do |app|
        ActiveSupport.on_load(:action_controller) do
          DecentExposure::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActionController::Base.send(:include, DecentExposure::DefaultExposure)
      ActionController::Base.protected_instance_variables.push("@_resources")
    end
  end
end
