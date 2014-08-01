require "adequate_exposure/version"
require "active_support/all"

module AdequateExposure
  autoload :Controller, "adequate_exposure/controller"
  autoload :Exposure,   "adequate_exposure/exposure"
  autoload :Attribute,  "adequate_exposure/attribute"
  autoload :Context,    "adequate_exposure/context"
  autoload :Flow,       "adequate_exposure/flow"

  ActiveSupport.on_load :action_controller do
    include Controller
  end
end
