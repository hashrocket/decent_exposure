require 'decent_exposure/active_record_strategy'

module DecentExposure
  class ActiveRecordWithEagerAttributesStrategy < ActiveRecordStrategy
    delegate :get?,    :to => :request
    delegate :delete?, :to => :request

    def singular?
      !plural?
    end

    def attributes
      params[options[:param_key] || inflector.param_key] || {}
    end

    def assign_attributes?
      return false unless attributes && singular?
      (!get? && !delete?) || new_record?
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
