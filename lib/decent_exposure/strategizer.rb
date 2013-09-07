require 'decent_exposure/exposure'
require 'decent_exposure/active_record_with_eager_attributes_strategy'
require 'decent_exposure/strong_parameters_strategy'

module DecentExposure
  class Strategizer
    attr_accessor :name, :block, :options, :custom_strategy_class

    def initialize(name, options={})
      self.name = name
      self.custom_strategy_class = options.delete(:strategy)
      self.options = options.merge(:name => name)
      self.block = Proc.new if block_given?
    end

    def strategy
      block_strategy || exposure_strategy
    end

    private

    def exposure_strategy
      Exposure.new(name, exposure_strategy_class, options)
    end

    def block_strategy
      BlockStrategy.new(block, exposure_strategy) if block
    end

    def exposure_strategy_class
      custom_strategy_class || ActiveRecordWithEagerAttributesStrategy
    end
  end

  BlockStrategy = Struct.new(:block, :exposure_strategy) do
    def call(controller)
      default = ExposureProxy.new(exposure_strategy, controller)
      controller.instance_exec(default, &block)
    end
  end

  class ExposureProxy
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

    def initialize(exposure, controller)
      @exposure, @controller = exposure, controller
    end

    def method_missing(*args)
      @target ||= @exposure.call(@controller)
      @target.send(*args)
    end
  end
end
