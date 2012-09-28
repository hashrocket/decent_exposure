require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

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
        context.const_get string.classify
      end
    end

    def parameter
      singular + "_id"
    end

    def singular
      string.parameterize
    end

    def plural
      string.pluralize
    end
    alias collection plural

    def plural?
      plural == string
    end
  end
end
