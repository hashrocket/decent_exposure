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
      ActionController::Base.class_eval do
        extend DecentExposure
        superclass_delegating_accessor(:_default_exposure)
        self.default_exposure = DecentExposure::ActiveModel
      end
    end
  end
end
