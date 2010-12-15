module DecentExposure
  class ActiveModel < Base
    def collection_name
      name.to_s.pluralize
    end

    def proxy
      if collection_name != name.to_s &&
          controller.respond_to?(collection_name) &&
          controller.send(collection_name).respond_to?(:scoped)
        controller.send(collection_name)
      else
        name.to_s.classify.constantize
      end
    end

    def id
      params["#{name}_id"] || params[:id]
    end

    def existing?
      !!id
    end

    def attributes
      params[name]
    end

    def new
      proxy.new(attributes)
    end

    def find
      proxy.find(id).tap do |r|
        r.attributes = attributes unless request.get?
      end
    end

    def instantiate
      if existing?
        find
      else
        new
      end
    end

    def call
      instantiate
    end
  end
end
