require 'decent_exposure/active_record'

module DecentExposure
  class Strategizer
    attr_reader :name, :block, :default_exposure
    def initialize(name, default_exposure)
      @name, @default_exposure = name, default_exposure
      @block = Proc.new if block_given?
    end

    def strategy
      if block
        BlockStrategy.new(block)
      elsif default_exposure
        DefaultStrategy.new(name, default_exposure)
      else
        ActiveRecord.new(name)
      end
    end
  end

  class DefaultStrategy < Struct.new(:name, :block)
    def call(controller)
      controller.instance_exec(name, &block)
    end
  end

  class BlockStrategy
    attr_reader :block
    def initialize(block)
      @block = block
    end
    def call(controller)
      controller.instance_eval(&block)
    end
  end
end
