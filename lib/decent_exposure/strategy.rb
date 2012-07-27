module DecentExposure
  class Strategy
    attr_reader :controller, :inflector, :options

    def initialize(controller, inflector, options={})
      @controller, @inflector, @options = controller, inflector, options
    end

    def name
      inflector.name
    end

    def resource
      raise 'Implement in subclass'
    end

    protected

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

    def params_method
      options[:params] || :params
    end
  end
end
