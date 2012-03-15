class DecentExposure::Naming
  attr_accessor :name
  def initialize(name)
    self.name = name
  end

  alias original name

  def plural
    # MAGIC, MAGIC, MAGIC!!
  end

  def singular

  end

  def model_name

  end

  def model
    const_get(model_name)
  end

  def to_sym
    name.to_sym
  end
end

class DecentExposure::Strategizer
  attr_accessor :framework, :orm

  def initialize(framework,orm,&blk)
    if block_given?
      yield
    else
      self.configured_framework = framework
      self.configured_orm = orm
    end
  end

  def orm
    configured_orm || DecentExposure::ActiveRecordAdapter
  end

  def framework
    configured_framework || DecentExposure::RailsAdapter
  end

  def orm=(orm)
    self.configured_framework = strategy_class(orm)
  end

  def framework=(framework)
    self.configured_framework = strategy_class(framework)
  end

  private
  def strategy_class(kind)
    const_get("DecentExposure::#{strategize(kind)}")
  end

  def strategize(kind)
    [classify(kind),'Strategy'].join
  end

  def classify(kind)
    kind.to_s.split('_').map{|s| s =~ /^(\w)(.*)/; [$1.upcase,$2].join }.join
  end

end

module DecentExposure::Config
  class_attribute :_strategizer
  def self.decent_config(framework=nil,orm=nil,&blk)
    self._strategizer = DecentExposure::Strategizer.new(framework,orm,&blk)
    self.orm_strategy = _strategizer.orm
  end

end

module DecentExposure::Expose
  attr_accessor :exposure
  def self.expose(name)
    self.exposure = DecentExposure::Exposure.new(self,name)
    define_method name do
      _resources[name] ||= exposure.call
    end
    framework.after_expose(name)
  end

  def _resources
    @_resources || {}
  end
end

class DecentExposure::Exposure
  attr_accessor :attributes
  attr_reader :name

  def initialize(controller, name)
    self.controller = controller
    self.name = name
  end

  def call
    if existing?
      orm.retrieve
    else
      orm.instantiate
    end
  end

  def name=(v)
    self.name = DecentExposure::Naming.new(name)
  end

  def existing?
    !!id
  end

  def id
    # #{name}_id, id or nil
  end

  def orm
    @orm ||= _strategizer.orm_strategy.new(controller,name)
  end

  def framework
    @framework ||= _strategizer.framework_strategy.new(controller,name)
  end

end

class DecentExposure::FrameworkStrategy
  def idempotent?
    raise "Implement in Subclass"
  end
  alias attributes idempotent?
end

class DecentExposure::ORMStrategy
  attr_accessor :name

  def initialize(controller, name)
    self.controller = controller
    self.name = name
  end

  def scope
    collection_resource || name.model.send(scoping_method)
  end

  def collection_resource
    if controller.respond_to?(name.plural)
      send(name.plural)
    end
  end

  def proxy
    if name.plural?
      scope
    else
      name.model
    end
  end

  def instantiate
    raise "Implement in Subclass"
  end
  alias retrieve instantiate
end

class DecentExposure::RailsStrategy < DecentExposure::FrameworkStrategy
  attr_accessor :controller, :name
  def initialize(controller,name)
    self.controller = controller
    self.name = name
  end

  def idempotent?
    controller.request.get?
  end

  def attributes
    controller.params[name]
  end

  def after_expose(name)
    controller.hide_action name
    controller.helper_method name
  end
end

class DecentExposure::ActiveRecordStrategy < DecentExposure::ORMStrategy
  def instantiate
    proxy.new(framework.attributes)
  end

  def retrieve(id)
    proxy.find(id).tap do |r|
      r.attributes = framework.attributes unless framework.idempotent?
    end
  end

  def scoping_method
    :scoped
  end
end


class ApplicationController
  decent_config(:sinatra,:datamapper)
  decent_config do
    framework :sinatra # SinatraStrategy
    orm :datamapper
  end
end

decent_strategy(:whatchamacallit) do
  model { ThingModel }
  finder
end

class WhatchamacallitStrategy
  
end

class Controller
  expose(:things)
  expose(:whatever, model: :thing)
  expose(:whatever, model: :thing, :finder: :find_by_thing, scope: :things)

  # filtering parameters
  expose(:whatever, attributes: [:ok, :also_ok])

  # using a custom / filtered set of parameters
  expose(:whatever, params: :whatever_params)
  def whatever_params
    attrs = params[:whatever] || {}
    if current_user.admin?
      attrs.slice(:ok, :also_ok, :ok_for_admin)
    else
      attrs.slice(:ok, :also_ok)
    end
  end

  # using the default behavior of decent_exposure with an app specific twist
  expose(:whatever, orm: :data_mapper) { app_specific(framework.execute_default) }

  def app_specific(object)
    AppSpecific.new(object)
  end

  # end

  exposure(:example) do
    orm :mem_cache
    model { Thing }
    finder :find_by_thing
    scope { model.scoped.further }
  end

  exposure(:affiliations) do
    scope { Affiliation.unscoped }
  end

  # uses the :affiliations exposure
  expose(:affiliations) do
    Decorator.new(framework.execute_default)
  end
  # Decorator.new(Affiliation.unscoped.find(params[:id]))

  exposure(:active_affiliations) do
    scope { Affiliation.unscoped.active }
  end

  expose(:affiliations, exposure: :active_affiliations) do
    framework.execute_default.paginate(params[:page])
  end
  # Affiliation.unscoped.active.find(params[:id]).paginate(params[:page])

  # avoiding conditionals

  # before
  expose(:whatever) do
    if controller.action == :foo
      SomethingTerrible.new
    else
      SomethingTerrible.new(params[:page])
    end
  end

  # yields to an instance of DecentExposure
  exposure(:default) do
    orm :active_record
    framework :rails
    model { orm.model_class }
    finder :where
    scope -> {}
  end

  exposure(:default, with: IndecentExposure) do
    orm :active_record
    framework :rails
    model { orm.model_class }
    finder :where
    scope -> {}
  end

  # after
  exposure(:something) do
    condition { controller.action == :foo }
    truthy { SomethingTerrible.new }
    falsey { SomethingTerrible.active.new }
    scope { Affiliation.unscoped.active }
  end

  expose(:whatever, exposure: :something)
  # end

end
