module AdequateExposure
  class Flow
    attr_reader :controller, :options
    delegate :params, to: :controller

    def initialize(controller, options)
      @controller, @options = controller, options.with_indifferent_access
    end

    def name
      options.fetch(:name)
    end

    %i[fetch find build build_params scope model id decorate].each do |method_name|
      define_method method_name do |*args|
        ivar_name = "@#{method_name}"
        return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
        instance_variable_set(ivar_name, handle_action(method_name, *args))
      end
    end

    protected

    def default_fetch
      computed_scope = scope(model)
      instance = id ? find(id, computed_scope) : build(build_params, computed_scope)
      decorate(instance)
    end

    def default_id
      params["#{name}_id"] || params[:id]
    end

    def default_scope(model)
      model
    end

    def default_model
      name.to_s.classify.constantize
    end

    def default_find(id, scope)
      scope.find(id)
    end

    def default_build(params, scope)
      scope.new(params)
    end

    def default_decorate(instance)
      instance
    end

    def default_build_params
      if controller.respond_to?(params_method_name, true) && !get_request?
        controller.send(params_method_name)
      else
        {}
      end
    end

    private

    def get_request?
      controller.request.get?
    end

    def params_method_name
      options.fetch(:build_params_method){ "#{name}_params" }
    end

    def handle_action(name, *args)
      if options.key?(name)
        handle_custom_action(name, *args)
      else
        send("default_#{name}", *args)
      end
    end

    def handle_custom_action(name, *args)
      value = options[name]

      if Proc === value
        args = args.first(value.parameters.length)
        controller.instance_exec(*args, &value)
      else
        fail ArgumentError, "Can't handle #{name.inspect} => #{value.inspect} option"
      end
    end
  end
end
