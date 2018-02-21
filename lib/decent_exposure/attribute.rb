module DecentExposure
  class Attribute
    attr_reader :name, :fetch, :ivar_name

    # Public: Initialize an Attribute
    #
    # options - Hash of options for the Attribute
    #           :name      - The String name of the Attribute instance
    #           :fetch     - The Proc fetch to calculate
    #                        the value of the Attribute instance.
    #                        This is only called if the attribute's
    #                        instance variable is not defined.
    #           :ivar_name - The String instance variable name that
    #                        is associated with the attribute.
    def initialize(options)
      @name = options.fetch(:name)
      @fetch = options.fetch(:fetch)
      @ivar_name = options.fetch(:ivar_name)
    end

    # Public: The getter method for the Attribute.
    #
    # Returns the name of the Attribute as a Symbol.
    def getter_method_name
      name.to_sym
    end

    # Public: The setter method for the Attribute.
    #
    # Returns the name of the attribute as a Symbol with an appended '='.
    def setter_method_name
      "#{name}=".to_sym
    end


    # Public: Expose a getter and setter method for the Attribute
    # on the passed in Controller class.
    #
    # klass - The Controller class where the Attribute getter and setter
    # methods will be exposed.
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
