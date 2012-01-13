require 'decent_exposure/active_record'

module DecentExposure
  class Exposure
    attr_reader :strategy

    def initialize(name)
      @strategy = if block_given?
                    Proc.new
                  else
                    ActiveRecord.new(name)
                  end
    end

    def call(*args)
      strategy.call(*args)
    end
  end
end
