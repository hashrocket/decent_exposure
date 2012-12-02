require 'fixtures/fake_rails_application'

# Models
class Parrot
  attr_accessor :beak
  extend ActiveModel::Naming
  def initialize(attrs={})
    self.attributes = attrs
  end
  def self.find(id)
    new if id
  end
  def attributes=(attributes)
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

module Admin
  class Parrot < ::Parrot
    def beak
      @beak ||= "admin"
    end
  end
end

class Albatross
  extend ActiveModel::Naming
  def self.scoped
    [new, new]
  end
end

class Organism
  extend ActiveModel::Naming
  attr_accessor :species
  def initialize(attrs={})
    self.attributes = attrs
  end
  def self.find_by_itis_id(itis_id)
    new
  end
  def self.find(id)
    new(:species => 'Striginae')
  end
  def attributes=(attributes)
    attributes.each { |k,v| send("#{k}=", v) }
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

class CustomStrategy < DecentExposure::Strategy
  def resource
    name + controller.params[:action]
  end
end

# Controllers
class BirdController < ActionController::Base
  include Rails.application.routes.url_helpers
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }
  expose(:albatrosses)
  expose(:parrot)

  expose(:logger) { "" }

  expose(:custom, :strategy => CustomStrategy)

  expose(:albert, :model => :parrot)
  expose(:bernard, :model => Admin::Parrot)

  decent_configuration(:custom) do
    strategy CustomStrategy
  end

  expose(:custom_from_config, :config => :custom)

  def show
    render :text => "Foo"
  end

  def new
    render :text => "new"
  end
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
  expose(:ducks) { DuckCollection.new }
  expose(:duck)

  expose(:custom_from_config, :config => :custom)
end

class MallardController < DuckController; end

class DefaultExposureController < ActionController::Base
  default_exposure do |name|
    name.to_s.upcase
  end

  expose :dodo
  expose(:penguin) { 'Happy Feet' }
end

class ChildDefaultExposureController < DefaultExposureController
  expose :eagle
end

class OverridingChildDefaultExposureController < DefaultExposureController
  default_exposure do |name|
    name.to_s.reverse
  end

  expose(:penguin)
end

class ::Model
  def self.find(*); new end
  def name; "outer" end
end

module ::Namespace
  class Model
    def self.find(*); new end
    def name; "inner" end
  end

  class ModelController < ActionController::Base
    include Rails.application.routes.url_helpers
    expose(:model)
    def show; render :text => ""; end
  end
end

class TaxonomiesController < ActionController::Base
  include Rails.application.routes.url_helpers

  decent_configuration do
    finder :find_by_itis_id
  end

  decent_configuration(:owl_find) do
    finder :find
  end

  expose(:organism)
  expose(:owl, :config => :owl_find, :model => :organism)

  def show
    render :text => 'show'
  end
end
