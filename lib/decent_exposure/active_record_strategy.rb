require 'decent_exposure/strategy'
require 'active_support/core_ext/module/delegation'

module DecentExposure
  class ActiveRecordStrategy < Strategy
    delegate :plural?, :parameter, :to => :inflector

    def collection
      inflector.plural.to_sym
    end

    def scope
      @scope ||= if ancestor
        ancestor_scope
      else
        default_scope
      end
    end

    def ancestor_scope
      return shallow_scope if options[:shallow] && member_route?

      if plural?
        controller.send(ancestor).send(inflector.plural)
      else
        controller.send(ancestor)
      end
    end

    def shallow_scope
      ancestor_exposure = controller.class._exposures[ancestor]
      if !params["#{ancestor}_id"] && ancestor_exposure.is_a?(DecentExposure::Exposure) && !controller._resources.has_key?(ancestor)
        # Prevents an infinite recursive loop, but we
        # may want to consider a different place holder
        controller._resources[ancestor] = DecentExposure

        if controller.respond_to?(inflector.singular)
          child = controller.send(inflector.singular)
        else
          raise MissingExposure.new("Please define a '#{inflector.singular}' exposure so decent_exposure can determine its '#{ancestor}' ancestor")
        end

        if child.respond_to?(ancestor)
          controller.send("#{ancestor}=", child.send(ancestor))
        else
          raise UnknownAncestor.new("The #{inflector.singular} exposure does not 'belong_to' the '#{ancestor}' ancestor")
        end
      end

      if plural?
        default_scope
      else
        model
      end
    end

    def default_scope
      if controller.respond_to?(collection) && !plural?
        controller.send(collection)
      else
        model
      end
    end

    def finder
      options[:finder] || :find
    end

    def collection_resource
      return scope if scope.respond_to?(:proxy_association) || scope.respond_to?(:each)
      scope.send(scope_method)
    end

    def id
      params[parameter] || params[finder_parameter]
    end

    def finder_parameter
      options[:finder_parameter] || :id
    end

    def singular_resource
      if id
        scope.send(finder, id)
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

    private

    def ancestor
      options[:ancestor]
    end

    def scope_method
      if defined?(ActiveRecord) && ActiveRecord::VERSION::MAJOR > 3
        :all
      else
        :scoped
      end
    end
  end
end
