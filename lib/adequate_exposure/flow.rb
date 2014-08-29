module AdequateExposure
  class Flow
    attr_reader :controller, :options, :name

    def initialize(controller, options)
      @controller = controller
      @options = options
      @name = options.fetch(:name)
    end

    def method_missing(name, *args, &block)
      if respond_to_missing?(name)
        handle_flow_method(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      Behavior.method_defined?(method_name) || super
    end

    private

    delegate :params, to: :controller

    def get_request?
      controller.request.get?
    end

    def params_method_name
      options.fetch(:build_params_method){ "#{name}_params" }
    end

    def handle_flow_method(name, *args, &block)
      fetch_ivar name do
        if options.key?(name)
          handle_options_override(name, *args, &block)
        else
          handle_default_flow_method(name, *args, &block)
        end
      end
    end

    def handle_options_override(name, *args)
      value = options[name]

      if Proc === value
        args = args.first(value.parameters.length)
        controller.instance_exec(*args, &value)
      else
        fail ArgumentError, "Can't handle #{name.inspect} => #{value.inspect} option"
      end
    end

    def handle_default_flow_method(name, *args, &block)
      method = Behavior.instance_method(name)
      method.bind(self).call(*args, &block)
    end


    def fetch_ivar(name)
      ivar_name = "@#{name}"

      if instance_variable_defined?(ivar_name)
        instance_variable_get(ivar_name)
      else
        instance_variable_set(ivar_name, yield)
      end
    end
  end
end
