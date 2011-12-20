module DecentExposure
  class Exposure
    attr_reader :strategy

    def initialize(name)
      @strategy = Proc.new if block_given?
    end

    def call
      strategy.call
    end
  end
end
