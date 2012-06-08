module DecentExposure
  class Strategy
    attr_reader :controller, :inflector, :options

    def initialize(controller, inflector, options={})
      @controller, @inflector, @options = controller, inflector, options
    end

    def name
      inflector.name
    end

    def options
      configuration.options.merge(@options)
    end

    def resource
      raise 'Implement in subclass'
    end

    protected

    def configuration
      controller.class._decent_configurations[config_method]
    end

    def model
      inflector.constant
    end

    def params
      controller.send(params_method)
    end

    def request
      controller.request
    end

    private

    def config_method
      @options[:config] || :default
    end

    def params_method
      options[:params] || :params
    end
  end
end
