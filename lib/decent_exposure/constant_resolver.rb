require 'active_support/inflector'
require 'active_support/core_ext/string'

module DecentExposure
  class ConstantResolver
    attr_reader :context, :constant_name
    def initialize(constant_name, context=Object)
      @context, @constant_name = context, constant_name.classify
    end

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
      namespace.const_get(constant_name)
    end

    def namespace
      path = context.to_s
      name = path[0...(path.rindex('::') || 0)]
      return Object if name.blank?
      name.constantize
    end
  end
end
