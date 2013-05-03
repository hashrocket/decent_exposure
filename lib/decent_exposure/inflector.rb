require 'active_support/inflector'
require 'active_support/core_ext/string'
require 'active_model/naming'

module DecentExposure
  class Inflector
    attr_reader :original, :model

    def initialize(name, model)
      @original = name.to_s
      @model = model
    end

    alias name original

    def model_name
      @model_name ||= if model.respond_to?(:model_name)
                        model.model_name
                      else
                        ActiveModel::Name.new(model)
                      end
    end

    delegate :singular, :plural, :param_key, :to => :model_name
    alias collection plural

    def parameter
      "#{model_name.singular}_id"
    end

    def plural?
      original.pluralize == original && !uncountable?
    end

    def uncountable?
      original.pluralize == original.singularize
    end
  end
end
