require 'fixtures/fake_rails_application'

class BirdController < ActionController::Base
  include Rails.application.routes.url_helpers
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }

  def show
    render :text => "Foo"
  end
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
end

class MallardController < DuckController; end
