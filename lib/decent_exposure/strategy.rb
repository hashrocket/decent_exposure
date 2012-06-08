module DecentExposure
  class Strategy
    attr_reader :controller, :inflector, :options

    def initialize(controller, inflector, options={})
      @controller, @inflector, @options = controller, inflector, options
    end

    def resource
      raise 'Implement in subclass'
    end

    def name
      inflector.name
    end

    protected

    def model
      inflector.constant
    end

    def request
      controller.request
    end

    def params
      controller.send(params_method)
    end

    private

    def params_method
      options[:params] || :params
    end
  end
end
