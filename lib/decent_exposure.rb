require 'decent_exposure/expose'

module DecentExposure
end

ActiveSupport.on_load(:action_controller) do
  extend DecentExposure::Expose
end
