module DecentExposure
  class Base
    attr_reader :controller, :name, :block

    def params
      controller.params
    end

    def request
      controller.request
    end

    def response
      controller.response
    end

    def headers
      controller.headers
    end

    def cookies
      controller.cookies
    end

    def session
      controller.session
    end

    def initialize(controller, name, &block)
      @controller = controller
      @name = name
      @block = block
    end
  end
end
