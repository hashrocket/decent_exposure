require 'decent_exposure/active_record_strategy'

module DecentExposure
  class StrongParametersStrategy < ActiveRecordStrategy
    delegate :get?,    :to => :request
    delegate :delete?, :to => :request

    def singular?
      !plural?
    end

    def attributes
      return @attributes if defined?(@attributes)
      if options[:permit].present?
        @attributes = params.require(name.to_sym).permit(*options[:permit])
      else
        @attributes = controller.send(options[:attributes]) if options[:attributes]
      end
    end

    def assign_attributes?
      singular? && !get? && !delete? && attributes.present?
    end

    def resource
      super.tap do |r|
        r.attributes = attributes if assign_attributes?
      end
    end
  end
end
