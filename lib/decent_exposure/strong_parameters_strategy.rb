require 'decent_exposure/active_record_strategy'
require 'decent_exposure/strategies/assign_from_method'

module DecentExposure
  class StrongParametersStrategy < ActiveRecordStrategy
    include Strategies::AssignFromMethod
  end
end
