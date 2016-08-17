module DecentExposure
  class Context
    attr_reader :context, :attribute

    # Public: Initialize a context.
    #
    # context   - The Class where the attribute is defined.
    # attribute - The attribute that will be accessed by a getter
    #             and setter.
    def initialize(context, attribute)
      @context, @attribute = context, attribute
    end

    # Public: Read an attribute on the context Class.
    #
    # Get an attribute's value. If the attribute's instance
    # variable is not defined, it will create one,
    # execute attribute#fetch, and assign the result
    # to the instance variable.
    #
    # Returns the attribute's value.
    def get
      ivar_defined?? ivar_get : set(fetch_value)
    end

    # Public: Write to an attribute on the context Class.
    #
    # value - The value that will be set to the attribute's
    #         instance variable.
    #
    # Returns the attribute's value.
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
      "@#{attribute.ivar_name.gsub('?', '_question_mark_')}"
    end

    def fetch_value
      context.instance_exec(&attribute.fetch)
    end
  end
end
