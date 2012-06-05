require 'decent_exposure/strategy'
require 'active_support/core_ext/module/delegation'

module DecentExposure
  class ActiveRecordStrategy < Strategy
    delegate :plural?, :parameter, :to => :inflector

    def collection
      inflector.plural.to_sym
    end

    def scope
      if controller.respond_to?(collection) && !plural?
        controller.send(collection)
      else
        model
      end
    end

    def collection_resource
      scope.scoped
    end

    def id
      params[parameter] || params[:id]
    end

    def singular_resource
      if id
        scope.find(id)
      else
        scope.new
      end
    end

    def resource
      if plural?
        collection_resource
      else
        singular_resource
      end
    end
  end
end
