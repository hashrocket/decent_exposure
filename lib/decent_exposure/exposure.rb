require 'decent_exposure/inflector'

module DecentExposure
  class Exposure
    attr_accessor :inflector, :strategy, :options

    def initialize(name, strategy, options)
      self.strategy = strategy
      self.options = options
      self.inflector = DecentExposure::Inflector.new(name, options[:model])
    end

    def call(controller)
      strategy.new(controller, inflector, options).resource
    end
  end
end
