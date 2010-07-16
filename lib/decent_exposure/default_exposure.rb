module DecentExposure
  module DefaultExposure
    def self.included(klass)
      klass.extend(DecentExposure)
      klass.superclass_delegating_accessor(:_default_exposure)
      klass.default_exposure do |name|
        self._resource_name = name.to_s
        if id = params["#{name}_id"] || params[:id]
          _proxy.find(id).tap do |r|
            r.attributes = params[name] unless request.get?
          end
        else
          _proxy.new(params[name])
        end
      end
    end

    private
    attr_accessor :_resource_name

    def _resource_class
      _resource_name.classify.constantize
    end

    def _collection_name
      _resource_name.pluralize
    end

    def _proxy
      _collection.respond_to?(:scoped) ? _collection : _resource_class
    end

    def _collection
      unless self.class.method_defined?(_collection_name)
        self.class.expose(_collection_name) do
          _collection_name.classify.constantize.scoped({})
        end
      end
      send(_collection_name)
    end
  end
end
