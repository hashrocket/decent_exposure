require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/string/inflections"

module AdequateExposure
  class Flow
    attr_reader :controller, :options
    delegate :params, to: :controller

    def initialize(controller, **options)
      @controller, @options = controller, HashWithIndifferentAccess.new(options)
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
      fetch_first_defined_param %I[#{name}_id id]
    end

    def default_scope
      model
    end

    def default_model
      symbol_to_class(name)
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

    def handle_custom_model(value)
      Class === value ? value : symbol_to_class(value)
    end

    def handle_custom_id(value)
      fetch_first_defined_param value
    end

    private

    def id_attribute_name
      Array.wrap(possible_id_keys).detect{ |key| params.key?(key) }
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
        controller.instance_exec(*args, &value)
      else
        send("handle_custom_#{name}", value, *args)
      end
    end

    def symbol_to_class(symbol)
      symbol.to_s.classify.constantize
    end

    def fetch_first_defined_param(keys)
      Array.wrap(keys).each do |key|
        return params[key] if params.key?(key)
      end

      nil
    end
  end
end
