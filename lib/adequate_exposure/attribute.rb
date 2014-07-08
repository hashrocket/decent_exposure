module AdequateExposure
  class Attribute
    attr_reader :name, :fetch, :ivar_name

    def initialize(options)
      @name = options.fetch(:name)
      @fetch = options.fetch(:fetch)
      @ivar_name = options.fetch(:ivar_name)
    end

    def getter_method_name
      name.to_sym
    end

    def setter_method_name
      "#{name}=".to_sym
    end

    def expose!(klass)
      attribute = self

      klass.instance_eval do
        define_method attribute.getter_method_name do
          Context.new(self, attribute).get
        end

        define_method attribute.setter_method_name do |value|
          Context.new(self, attribute).set(value)
        end
      end
    end
  end
end
