module DecentExposure
  module DefaultExposure
    def self.included(klass)
      klass.extend(DecentExposure)
      klass.extend(DefaultExposureFinder)
      if klass.respond_to?(:class_attribute)
        klass.class_attribute(:_default_exposure)
      else
        klass.superclass_delegating_accessor(:_default_exposure)
      end
      klass.default_exposure do |name|
        collection = name.to_s.pluralize
        if respond_to?(collection) && collection != name.to_s && send(collection).respond_to?(:scoped)
          proxy = send(collection)
        else
          proxy = name.to_s.classify.constantize
        end

        if id = params["#{name}_id"] || params[:id]
          proxy.send(self.class.default_exposure_finder, id).tap do |r|
            r.attributes = params[name] unless request.get?
          end
        else
          proxy.new(params[name])
        end
      end
    end
  end
end
