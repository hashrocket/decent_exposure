require 'fixtures/fake_rails_application'

# Models
class Parrot
  extend ActiveModel::Naming
  def self.find(*)
    new
  end
end

# Controllers
class BirdController < ActionController::Base
  include Rails.application.routes.url_helpers
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }
  expose(:parrot)

  def show
    render :text => "Foo"
  end
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
end

class MallardController < DuckController; end
