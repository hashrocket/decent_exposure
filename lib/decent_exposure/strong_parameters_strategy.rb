require 'decent_exposure/active_record_strategy'
require 'decent_exposure/strategies/assign_from_method'

module DecentExposure
  class StrongParametersStrategy < ActiveRecordStrategy
    include Strategies::AssignFromMethod

    def assign_attributes?
      singular? && !get? && !delete? && (params[options[:param_key] || inflector.param_key]).present?
    end
  end
end
