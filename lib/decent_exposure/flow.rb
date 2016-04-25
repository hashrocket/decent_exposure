module DecentExposure
  class Flow
    attr_reader :controller, :options, :name

    # Public: Initialize a Flow. This object responds to missing
    # methods errors and attempts to delegate them to other objects.
    #
    # controller - The Controller class where the method was called.
    # options    - The options Hash of the Exposure instance being called.
    # name       - The String name of the Exposure instance.
    def initialize(controller, options)
      @controller = controller
      @options = options
      @name = options.fetch(:name)
    end

    # Public: Attempts to re-delegate a method missing to the
    # supplied block or the Behavior object.
    #
    # name  - The String name of the Exposure instance.
    # *args - The arguments given for the missing method.
    # block - The Proc invoked by the method.
    def method_missing(name, *args, &block)
      if respond_to_missing?(name)
        handle_flow_method(name, *args, &block)
      else
        super
      end
    end

    # Public: Checks if the Behavior class can handle the missing method.
    #
    # method_name     - The name of method that has been called.
    # include_private - Prevents this method from catching calls to private
    # method (default: false).
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
