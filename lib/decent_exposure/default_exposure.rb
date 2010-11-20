module DecentExposure
  module DefaultExposure
    def self.included(klass)
      klass.extend(DecentExposure)
      klass.superclass_delegating_accessor(:_default_exposure)
      klass.default_exposure do |name|
        collection = name.to_s.pluralize
        if respond_to?(collection) && send(collection).respond_to?(:scoped)
          proxy = send(collection)
        else
          proxy = name.to_s.classify.constantize
        end

        if id = params["#{name}_id"] || params[:id]
          proxy.find(id).tap do |r|
            r.attributes = params[name] unless request.get?
          end
        else
          proxy.new(params[name])
        end
      end
    end
  end
end
