require 'decent_exposure/inflector'

module DecentExposure
  class Exposure
    attr_reader :inflector, :strategy

    def initialize(name, strategy)
      @strategy = strategy
      @inflector = DecentExposure::Inflector.new(name)
    end

    def call(controller)
      strategy.new(controller, inflector).resource
    end
  end
end
