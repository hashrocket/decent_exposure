require 'decent_exposure/inflector'
require 'decent_exposure/constant_resolver'

module DecentExposure
  class Strategy
    attr_reader :controller, :name, :options
    attr_writer :model, :inflector

    def initialize(controller, name, options={})
      @controller, @name, @options = controller, name.to_s, options
    end

    def resource
      raise 'Implement in subclass'
    end

    protected

    def inflector
      @inflector ||= DecentExposure::Inflector.new(name, model)
    end

    def model
      @model ||= case options[:model]
                 when Class, Module
                   options[:model]
                 else
                   name_or_model = options[:model] || name
                   DecentExposure::ConstantResolver.new(name_or_model.to_s, controller.class).constant
                 end
    end

    def params
      controller.send(params_method)
    end

    def request
      controller.request
    end

    def member_route?
      params.has_key?(:id)
    end

    def collection_route?
      !member_route?
    end

    private

    def params_method
      options[:params] || :params
    end
  end
end
