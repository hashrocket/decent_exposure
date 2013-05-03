require 'active_support/inflector'
require 'active_support/core_ext/string'

module DecentExposure
  class Inflector
    attr_reader :string, :original, :model
    alias name string

    def initialize(name, model)
      @original = name.to_s
      @model = model
      @string = model.to_s.demodulize.downcase
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
      original.pluralize == original && !uncountable?
    end

    def uncountable?
      original.pluralize == original.singularize
    end
  end
end
