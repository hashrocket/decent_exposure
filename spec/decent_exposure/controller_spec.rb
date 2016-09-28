require "spec_helper"

RSpec.describe DecentExposure::Controller do
  class Thing; end
  class DifferentThing; end

  class BaseController
    def self.helper_method(*); end

    def params
      @params ||= HashWithIndifferentAccess.new
    end
  end

  let(:controller_klass) do
    Class.new(BaseController) do
      include DecentExposure::Controller
    end
  end

  let(:request){ double("Request") }
  let(:controller){ controller_klass.new }
  before{ allow(controller).to receive(:request){ request } }

  %w[expose expose! exposure_config].each do |method_name|
    define_method method_name do |*args, &block|
      controller_klass.send method_name, *args, &block
    end
  end

  context "getter/setter methods" do
    before{ expose :thing }

    it "defines getter method" do
      expect(controller).to respond_to(:thing)
    end

    it "defines setter method" do
      expect(controller).to respond_to(:thing=).with(1).argument
    end
  end

  context "helper methods" do
    it "exposes getter as controller helper methods" do
      expect(controller_klass).to receive(:helper_method).with(:thing)
      expose :thing
    end

    it "does not expose setter as controller helper methods" do
      expect(controller_klass).to_not receive(:helper_method).with(:thing=)
      expose :thing
    end
  end

  context ".expose!" do
    it "supports eager expose" do
      expect(controller_klass).to receive(:before_action).with(:thing)
      expose! :thing
    end
  end

  context ".exposure_config" do
    it "subclass configration doesn't propagate to superclass" do
      controller_subklass = Class.new(controller_klass)
      controller_klass.exposure_config :foo, :bar
      controller_subklass.exposure_config :foo, :lol
      controller_subklass.exposure_config :fizz, :buzz
      expect(controller_subklass.exposure_configuration).to eq(foo: :lol, fizz: :buzz)
      expect(controller_klass.exposure_configuration).to eq(foo: :bar)
    end

    context "applying" do
      let(:thing){ double("Thing") }

      before do
        exposure_config :sluggable, find_by: :slug
        exposure_config :weird_id_name, id: :check_this_out
        exposure_config :another_id_name, id: :whee
        exposure_config :multi, find_by: :slug, id: :check_this_out
        controller.params.merge! check_this_out: "foo", whee: "wut"
      end

      after{ expect(controller.thing).to eq(thing) }

      it "can be reused later" do
        expose :thing, with: :weird_id_name
        expect(Thing).to receive(:find).with("foo").and_return(thing)
      end

      it "can apply multple configs at once" do
        expose :thing, with: [:weird_id_name, :sluggable]
        expect(Thing).to receive(:find_by!).with(slug: "foo").and_return(thing)
      end

      it "applies multiple configs in a correct order" do
        expose :thing, with: [:another_id_name, :weird_id_name]
        expect(Thing).to receive(:find).with("wut").and_return(thing)
      end

      it "can apply multiple options in a config" do
        expose :thing, with: :multi
        expect(Thing).to receive(:find_by!).with(slug: "foo").and_return(thing)
      end

      it "applies multiple configs with multiple options in a correct order" do
        expose :thing, with: [:another_id_name, :multi]
        expect(Thing).to receive(:find_by!).with(slug: "wut").and_return(thing)
      end
    end
  end

  context "with block" do
    before{ expose(:thing){ compute_thing } }

    it "executes block to calculate the value" do
      allow(controller).to receive(:compute_thing).and_return(42)
      expect(controller.thing).to eq(42)
    end

    it "executes the block once and memoizes the result" do
      expect(controller).to receive(:compute_thing).once.and_return(42)
      10.times{ controller.thing }
    end

    it "allows setting value directly" do
      expect(controller).to_not receive(:compute_thing)
      controller.thing = :foobar
      expect(controller.thing).to eq(:foobar)
    end

    it "throws and error when providing options with block" do
      action = ->{ expose(:thing, id: :some_id){ some_code } }
      expect(&action).to raise_error(ArgumentError, "Using :fetch option with other options doesn't make sense")
    end
  end

  context "passing fetch block as an argument instead of block" do
    it "is equivalent to passing block" do
      expose :thing, ->{ compute_thing }
      expect(controller).to receive(:compute_thing).and_return(42)
      expect(controller.thing).to eq(42)
    end

    it "throws an error when passing both block and block-argument" do
      action = ->{ expose(:thing, ->{}){} }
      expect(&action).to raise_error(ArgumentError, "Fetch block is already defined")
    end
  end

  context "passing fetch block as a symbol" do
    it "is equivalent to passing a block alling controller method" do
      expose :thing, :calculate_thing_in_controller
      expect(controller).to receive(:calculate_thing_in_controller).and_return(42)
      expect(controller.thing).to eq(42)
    end
  end

  context "redefine fetch" do
    before do
      expose :thing, fetch: ->{ compute_thing }
      allow(controller).to receive(:compute_thing).and_return(42)
    end

    it "uses provided fetch proc instead of default" do
      expect(controller.thing).to eq(42)
    end
  end

  context "default behaviour" do
    context "build" do
      let(:thing){ double("Thing") }

      after{ expect(controller.thing).to eq(thing) }

      context "params method is not available" do
        it "builds a new instance with empty hash" do
          expose :thing
          expect(Thing).to receive(:new).with({}).and_return(thing)
        end
      end

      context "params method is available" do
        it "ignores params on get request" do
          expose :thing
          expect(request).to receive(:get?).and_return(true)
          expect(controller).not_to receive(:thing_params)
          expect(Thing).to receive(:new).with({}).and_return(thing)
        end

        it "uses params method on non-get request" do
          expose :thing
          expect(request).to receive(:get?).and_return(false)
          expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
          expect(controller).to receive(:thing_params).and_return(foo: :bar)
        end

        it "can use custom params method name" do
          expose :thing, build_params: :custom_params_method_name
          expect(request).to receive(:get?).and_return(false)
          expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
          expect(controller).to receive(:custom_params_method_name).and_return(foo: :bar)
        end

        it "can use custom build params" do
          expose :thing, build_params: ->{ foobar }
          expect(controller).to receive(:foobar).and_return(42)
          expect(Thing).to receive(:new).with(42).and_return(thing)
        end
      end
    end

    context "find" do
      before do
        expose :thing, model: :different_thing
        expect(DifferentThing).to receive(:find).with(10)
      end

      after{ controller.thing }

      it "checks params[:different_thing_id] first" do
        controller.params.merge! different_thing_id: 10, thing_id: 11, id: 12
      end
      it "checks params[:thing_id] second" do
        controller.params.merge! thing_id: 10, id: 11
      end

      it "checks params[:id] in the end" do
        controller.params.merge! id: 10
      end
    end
  end

  context "find_by" do
    it "throws and error when using with :find" do
      action = ->{ expose :thing, find: :foo, find_by: :bar }
      expect(&action).to raise_error(ArgumentError, "Using :find_by option with :find doesn't make sense")
    end

    it "allows to specify what attribute to use for find" do
      expect(Thing).to receive(:find_by!).with(foo: 10).and_return(42)
      expose :thing, find_by: :foo
      controller.params.merge! id: 10
      expect(controller.thing).to eq(42)
    end
  end

  context "parent option" do
    context "with scope/model options" do
      it "throws an error when used with scope option" do
        action = ->{ expose :thing, scope: :foo, parent: :something }
        expect(&action).to raise_error(ArgumentError, "Using :parent option with :scope doesn't make sense")
      end

      it "throws an error when used with model option" do
        action = ->{ expose :thing, model: :foo, parent: :something }
        expect(&action).to raise_error(ArgumentError, "Using :parent option with :model doesn't make sense")
      end
    end

    context "build/find" do
      let(:current_user){ double("User") }
      let(:scope){ double("Scope") }

      before do
        expect(controller).to receive(:current_user).and_return(current_user)
        expect(current_user).to receive(:things).and_return(scope)
        expose :thing, parent: :current_user
      end

      after{ expect(controller.thing).to eq(42) }

      it "sets the scope to belong to parent defined by controller method" do
        expect(scope).to receive(:new).with({}).and_return(42)
      end

      it "scopes the find to proper scope" do
        controller.params.merge! thing_id: 10
        expect(scope).to receive(:find).with(10).and_return(42)
      end
    end
  end

  context "override model" do
    let(:different_thing){ double("DifferentThing") }
    before{ expect(DifferentThing).to receive(:new).with({}).and_return(different_thing) }
    after{ expect(controller.thing).to eq(different_thing) }

    it "allows overriding model class with proc" do
      expose :thing, model: ->{ DifferentThing }
    end

    it "allows overriding model with class" do
      expose :thing, model: DifferentThing
    end

    it "allows overriding model class with symbol" do
      expose :thing, model: :different_thing
    end

    it "allows overriding model class with string" do
      expose :thing, model: "DifferentThing"
    end
  end

  context "override scope" do
    it "allows overriding scope with proc" do
      scope = double("Scope")
      expose :thing, scope: ->{ scope }
      expect(scope).to receive(:new).and_return(42)
      expect(controller.thing).to eq(42)
    end

    it "allows overriding model scope using symbol" do
      scope = double("Scope")
      expect(Thing).to receive(:custom_scope).and_return(scope)
      expect(scope).to receive(:new).and_return(42)
      expose :thing, scope: :custom_scope
      expect(controller.thing).to eq(42)
    end
  end

  context "override id" do
    after do
      expect(Thing).to receive(:find).with(42)
      controller.thing
    end

    it "allows overriding id with proc" do
      expose :thing, id: ->{ get_thing_id_somehow }
      expect(controller).to receive(:get_thing_id_somehow).and_return(42)
    end

    it "allows overriding id with symbol" do
      expose :thing, id: :custom_thing_id
      controller.params.merge! thing_id: 10, custom_thing_id: 42
    end

    it "allows overriding id with an array of symbols" do
      expose :thing, id: %w[non-existent-id lolwut another_id_param]
      controller.params.merge! another_id_param: 42
    end
  end

  context "override decorator" do
    it "allows specify decorator" do
      expose :thing, decorate: ->(thing){ decorate(thing) }
      thing = double("Thing")
      expect(Thing).to receive(:new).with({}).and_return(thing)
      expect(controller).to receive(:decorate).with(thing)
      controller.thing
    end
  end

  context "from option" do
    it "allows scope to be called from method" do
      comments = double("Comments")
      post = double("Post", comments: comments)
      allow(controller).to receive(:post).and_return(post)
      expose :comments, from: :post

      expect(controller.comments).to eq(comments)
    end

    it "should throw error when used with other options" do
      action = ->{ expose :thing, from: :foo, parent: :bar }
      expect(&action).to raise_error(ArgumentError, "Using :from option with other options doesn't make sense")
    end

    it "should still work with decorate option" do
      decorated_thing = double("DecoratedThing")
      thing = double("Thing")
      foo = double("Foo", thing: thing)
      expect(controller).to receive(:foo).and_return(foo)
      expect(controller).to receive(:decorate).with(thing).and_return(decorated_thing)
      expose :thing, from: :foo, decorate: ->(thing){ decorate(thing) }
      expect(controller.thing).to eq(decorated_thing)
    end
  end
end
