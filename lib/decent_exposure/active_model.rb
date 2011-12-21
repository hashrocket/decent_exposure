require 'decent_exposure/inflector'

module DecentExposure
  class ActiveModel
    attr_reader :name, :inflector

    def initialize(name)
      @name = name
      @inflector = ::DecentExposure::Inflector.new(name)
    end

    def model
      inflector.constant
    end

    def parameter
      inflector.parameter
    end

    def call(params)
      model.find(params[:id] || params[parameter])
    end
  end
end
