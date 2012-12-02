require 'decent_exposure/exposure'
require 'decent_exposure/active_record_with_eager_attributes_strategy'

module DecentExposure
  class Strategizer
    attr_accessor :name, :block, :default_exposure, :options, :custom_strategy_class

    def initialize(name, options={})
      self.name = name
      self.default_exposure = options.delete(:default_exposure)
      self.custom_strategy_class = options.delete(:strategy)
      self.options = options
      self.block = Proc.new if block_given?
    end

    def strategy
      [block_strategy,
       default_exposure_strategy,
       exposure_strategy].detect(&applicable)
    end

    def model
      options[:model] || name
    end

    private

    def applicable
      lambda { |s| s }
    end

    def exposure_strategy
      Exposure.new(model, exposure_strategy_class, options)
    end

    def block_strategy
      BlockStrategy.new(block) if block
    end

    def default_exposure_strategy
      DefaultStrategy.new(name, default_exposure) if default_exposure
    end

    def exposure_strategy_class
      custom_strategy_class || ActiveRecordWithEagerAttributesStrategy
    end
  end

  DefaultStrategy = Struct.new(:name, :block) do
    def call(controller)
      controller.instance_exec(name, &block)
    end
  end

  BlockStrategy = Struct.new(:block) do
    def call(controller)
      controller.instance_eval(&block)
    end
  end
end
