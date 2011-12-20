require 'active_support/all'
require 'action_controller'
require 'decent_exposure/expose'

class FooController < ActionController::Base
  extend DecentExposure::Expose
  expose(:foo) { "bar" }

  def action
    foo
  end
end
