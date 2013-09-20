require 'decent_exposure/expose'
require 'decent_exposure/error'

ActiveSupport.on_load(:action_controller) do
  extend DecentExposure::Expose
end
