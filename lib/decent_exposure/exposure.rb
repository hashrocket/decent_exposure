require 'decent_exposure/active_record'

module DecentExposure
  class Exposure
    attr_reader :strategy

    def initialize(name)
      @strategy = if block_given?
                    BlockStrategy.new(Proc.new)
                  else
                    ActiveRecord.new(name)
                  end
    end

    def call(*args)
      strategy.call(*args)
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
