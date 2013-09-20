require 'decent_exposure/active_record_strategy'
require 'decent_exposure/strategies/assign_from_params'

module DecentExposure
  class ActiveRecordWithEagerAttributesStrategy < ActiveRecordStrategy
    include Strategies::AssignFromParams
  end
end
