module DecentExposure
  module Behavior
    # Public: Fetches a scope.
    #
    # Finds an object. If it isn't found, the object gets instantiated.
    #
    # Returns the decorated object.
    def fetch
      instance = if id
        find(id, computed_scope)
      else
        shallow_child ? controller.send(shallow_child).send(name) : build(build_params, computed_scope)
      end

      decorate(instance)
    end

    # Public: Checks a params hash for an id attribute.
    #
    # Checks a hash of parameters for keys that represent an object's id.
    #
    # Returns the value of the id parameter, if it exists. Otherwise nil.
    def id
      params_id_key_candidates.each do |key|
        value = params[key]
        return value if value.present?
      end

      nil
    end

    # Public: An object query. Essentially, this method is designed to be
    # overridden.
    #
    # model - The Class to be scoped or queried.
    #
    # Returns the object scope.
    def scope(model)
      if shallow_parent
        shallow_parent_exposure.id ? controller.send(shallow_parent).send(name.to_s.pluralize) : model
      else
        model
      end
    end

    # Public: Converts a name into a standard Class name.
    #
    # Examples
    #   'egg_and_hams'.model # => EggAndHam
    #
    # Returns a standard Class name.
    def model
      name.to_s.classify.constantize
    end

    # Public: Find an object on the supplied scope.
    #
    # id    - The Integer id attribute of the desired object
    # scope - The collection that will be searched.
    #
    # Returns the found object.
    def find(id, scope)
      scope.find(id)
    end

    # Public: Builds a new object on the passed-in scope.
    #
    # params - A Hash of attributes for the object to-be built.
    # scope  - The collection that will be searched.
    #
    # Returns the new object.
    def build(params, scope)
      scope.new(params)
    end

    # Public: Returns a decorated object. This method is designed to be
    # overridden.
    #
    # Returns the decorated object.
    def decorate(instance)
      instance
    end

    # Public: Get all the parameters of the current request.
    #
    # Returns the controller's parameters for the current request.
    def build_params
      if controller.respond_to?(params_method_name, true) && !get_request?
        controller.send(params_method_name)
      else
        {}
      end
    end

    # Public: Set the shallow routes parent from which to derive the child
    #
    # Returns the shallow routes parent exposure symbol
    def shallow_parent; end

    # Public: Set the shallow routes child from which to derive the parent
    #
    # Returns the shallow routes child exposure symbol
    def shallow_child; end

    protected

    def params_id_key_candidates
      [].tap do |array|
        array.concat([ "#{model_param_key}_id", "#{name}_id" ].uniq) unless shallow_parent
        array << "id" unless shallow_child
      end
    end

    def model_param_key
      model.name.underscore
    end

    def computed_scope
      scope(model)
    end

    def shallow_parent_exposure; end

  end
end
