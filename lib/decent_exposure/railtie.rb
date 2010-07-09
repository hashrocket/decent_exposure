module DecentExposure
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer "decent_exposure.extend_action_controller_base" do |app|
        ActionController::Base.class_eval do
          extend DecentExposure
          superclass_delegating_accessor :_default_exposure
          default_exposure do |name|
            model_class = name.to_s.classify.constantize
            model_class.find(params["#{name}_id"] || params['id'])
          end
        end
      end
    end
  end
end
