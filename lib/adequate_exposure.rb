require "active_support/core_ext"

module AdequateExposure
  autoload :Controller, "adequate_exposure/controller"
  autoload :Exposure,   "adequate_exposure/exposure"
  autoload :Attribute,  "adequate_exposure/attribute"
  autoload :Context,    "adequate_exposure/context"
  autoload :Flow,       "adequate_exposure/flow"

  ActiveSupport.on_load :action_controller do
    extend Controller
  end
end
