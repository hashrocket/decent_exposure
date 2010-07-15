module DecentExposure
  module DefaultExposure
    def self.included(klass)
      klass.extend(DecentExposure)
      klass.superclass_delegating_accessor(:_default_exposure)
      klass.default_exposure do |name|
        self._designation = name.to_s.pluralize
        if id = params["#{name}_id"] || params[:id]
          _collection.find(id).tap do |r|
            r.attributes = params[name] unless request.get?
          end
        else
          _collection.new(params[name])
        end
      end
    end

    private
    attr_accessor :_designation
    attr_writer :_collection_name

    def _collection_name
      @_collection_name || _designation
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
