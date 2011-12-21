require 'decent_exposure/active_model'

module DecentExposure
  class Exposure
    attr_reader :strategy

    def initialize(name)
      @strategy = if block_given?
                    Proc.new
                  else
                    ActiveModel.new(name)
                  end
    end

    def call(*args)
      strategy.call(*args)
    end
  end
end
