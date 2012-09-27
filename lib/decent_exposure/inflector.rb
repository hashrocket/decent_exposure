require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module DecentExposure
  class Inflector
    attr_reader :original
    alias name original

    def initialize(name)
      @original = name.to_s
    end

    def constant
      original.classify.constantize
    end

    def parameter
      singular + "_id"
    end

    def singular
      original.demodulize.parameterize
    end

    def plural
      original.demodulize.pluralize
    end
    alias collection plural

    def plural?
      plural == original
    end
  end
end
