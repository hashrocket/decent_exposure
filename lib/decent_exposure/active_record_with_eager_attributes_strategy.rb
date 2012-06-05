require 'decent_exposure/active_record_strategy'

module DecentExposure
  class ActiveRecordWithEagerAttributesStrategy < ActiveRecordStrategy
    delegate :get?, :to => :request

    def singular?
      !plural?
    end

    def attributes
      params[inflector.singular]
    end

    def assign_attributes?
      return false unless attributes && singular?
      !get? || new_record?
    end

    def new_record?
      !id
    end

    def resource
      super.tap do |r|
        r.attributes = attributes if assign_attributes?
      end
    end
  end
end
