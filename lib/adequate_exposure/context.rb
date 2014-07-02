module AdequateExposure
  class Context
    attr_reader :context, :attribute

    def initialize(context, attribute)
      @context, @attribute = context, attribute
    end

    def get
      ivar_defined?? ivar_get : set(fetch_value)
    end

    def set(value)
      ivar_set(value)
    end

    private

    delegate :instance_variable_set, :instance_variable_get,
      :instance_variable_defined?, to: :context

    def ivar_defined?
      instance_variable_defined?(ivar_name)
    end

    def ivar_get
      instance_variable_get(ivar_name)
    end

    def ivar_set(value)
      instance_variable_set(ivar_name, value)
    end

    def ivar_name
      "@#{attribute.ivar_name}"
    end

    def fetch_value
      context.instance_exec(&attribute.fetch)
    end
  end
end
