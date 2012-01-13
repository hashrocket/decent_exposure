require 'fixtures/fake_rails_application'

# Models
class Parrot
  attr_accessor :beak
  extend ActiveModel::Naming
  def self.find(*)
    new
  end
  def attributes=(attributes)
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

class Albatross
  extend ActiveModel::Naming
  def self.scoped
    [new, new]
  end
end

Duck = Struct.new(:id)

class DuckCollection
  def ducks
    @ducks ||= [Duck.new("quack"), Duck.new("burp")]
  end

  def find(id)
    ducks.detect { |d| d.id == id }
  end
end

# Controllers
class BirdController < ActionController::Base
  include Rails.application.routes.url_helpers
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }
  expose(:albatrosses)
  expose(:parrot)

  def show
    render :text => "Foo"
  end
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
  expose(:ducks) { DuckCollection.new }
  expose(:duck)
end

class MallardController < DuckController; end
