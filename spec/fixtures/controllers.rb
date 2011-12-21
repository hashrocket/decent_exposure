require 'active_support/all'
require 'action_controller'
require 'decent_exposure/expose'

class BirdController < ActionController::Base
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
end

class MallardController < DuckController; end
