module DecentExposure
  class Configuration
    def initialize(&block)
      instance_exec(&block) if block_given?
    end

    def options
      @options ||= {}
    end

    def method_missing(key,value)
      self.options[key] = value
    end
  end
end
