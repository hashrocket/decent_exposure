require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module DecentExposure
  class Inflector
    attr_reader :original

    def initialize(name)
      @original = name.to_s
    end

    def constant
      original.classify.constantize
    end

    def parameter
      original.parameterize + "_id"
    end

    def plural?
      original.pluralize == original
    end
  end
end
