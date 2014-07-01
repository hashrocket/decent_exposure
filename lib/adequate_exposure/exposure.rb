module AdequateExposure
  class Exposure
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def expose!(controller)
      expose_attribute! controller
      expose_helper_methods! controller
    end

    private

    def expose_attribute!(controller)
      attribute.expose! controller
    end

    def expose_helper_methods!(controller)
      helper_methods = [ attribute.getter_method_name, attribute.setter_method_name ]
      controller.helper_method *helper_methods
    end

    def attribute
      @attribute ||= begin
        local_options = options

        name = options.fetch(:name)
        ivar_name = "exposed_#{name}"
        fetch = ->{ Flow.new(self, local_options).fetch }

        Attribute.new(
          name: name,
          ivar_name: ivar_name,
          fetch: fetch
        )
      end
    end
  end
end
