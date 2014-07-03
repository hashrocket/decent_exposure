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

    %i[fetch find build scope model id decorate].each do |method_name|
      define_method method_name do |*args|
        ivar_name = "@#{method_name}"
        return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
        instance_variable_set(ivar_name, handle_action(method_name, *args))
      end
    end

    protected

    def default_fetch
      id ? decorate(find(id, scope)) : decorate(build(scope))
    end

    def default_id
      params["#{name}_id"] || params[:id]
    end

    def default_scope
      model
    end

    def default_model
      name.to_s.classify.constantize
    end

    def default_find(id, scope)
      scope.find(id)
    end

    def default_build(scope)
      scope.new
    end

    def default_decorate(instance)
      instance
    end

    private

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
        controller.instance_exec(*args, &value)
      else
        fail ArgumentError, "Can't handle #{name.inspect} => #{value.inspect} option"
      end
    end
  end
end
