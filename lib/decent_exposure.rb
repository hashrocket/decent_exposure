require 'decent_exposure/expose'

ActiveSupport.on_load(:action_controller) do
  extend DecentExposure::Expose
end
