require 'active_support/inflector'
require 'active_support/core_ext/string'

module DecentExposure
  class Inflector
    attr_reader :string, :original
    alias name string

    def initialize(name)
      @original = name
      @string = name.to_s.demodulize
    end

    def constant(context=Object)
      case original
      when Module, Class
        original
      else
        ConstantResolver.new(context, string.classify).constant
      end
    end

    def parameter
      singular + "_id"
    end

    def singular
      @singular ||= string.singularize.parameterize
    end

    def plural
      string.pluralize
    end
    alias collection plural

    def plural?
      plural == string && !uncountable?
    end

    def uncountable?
      plural == singular
    end

    private

    ConstantResolver = Struct.new :context, :constant_name do

      def constant
        immediate_child || namespace_qualified
      end

      private

      def immediate_child
        context.constants.map do |c|
          context.const_get(c) if c.to_s == constant_name
        end.compact.first
      end

      def namespace_qualified
        context.to_s.deconstantize.constantize.const_get(constant_name)
      end
    end
  end
end
