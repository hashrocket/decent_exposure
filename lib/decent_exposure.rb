require 'decent_exposure/expose'
require 'decent_exposure/exception'

ActiveSupport.on_load(:action_controller) do
  extend DecentExposure::Expose
end
