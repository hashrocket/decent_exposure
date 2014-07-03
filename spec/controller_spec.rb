require "spec_helper"

describe AdequateExposure::Controller do
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
      extend AdequateExposure::Controller
    end
  end

  let(:controller){ controller_klass.new }

  def expose(*args, &block)
    controller_klass.expose(*args, &block)
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
    it "exposes getter and setter as controller helper methods" do
      expect(controller_klass).to receive(:helper_method).with(:thing, :thing=)
      expose :thing
    end
  end

  context ".expose!" do
    it "supports eager expose" do
      expect(controller_klass).to receive(:before_action).with(:thing)
      controller_klass.expose! :thing
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

      it "builds a new instance with empty hash when strong parameters method is not available" do
        expose :thing
        expect(Thing).to receive(:new).with({}).and_return(thing)
      end

      it "builds a new instance with attributes when strong parameters method is available" do
        expose :thing
        expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
        expect(controller).to receive(:thing_params).and_return(foo: :bar)
      end

      it "allows to specify strong parameters method name with a symbol passed to build option" do
        expose :thing, build: :custom_params_method_name
        expect(Thing).to receive(:new).with(foo: :bar).and_return(thing)
        expect(controller).to receive(:custom_params_method_name).and_return(foo: :bar)
      end
    end

    context "find" do
      before do
        expose :thing
        expect(Thing).to receive(:find).with(10)
      end

      after{ controller.thing }

      it "finds Thing if thing_id param is provided" do
        controller.params.merge! thing_id: 10
      end

      it "finds Thing if id param if provided" do
        controller.params.merge! id: 10
      end
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
      expose :thing, id: %i[non-existent-id lolwut another_id_param]
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
      post = double("Post")
      comments = double("Comments")
      allow(controller).to receive(:post).and_return(post)
      expect(post).to receive(:comments).and_return(comments)
      expose :comments, from: :post

      expect(controller.comments).to eq(comments)
    end

    it "should throw error when used with other options" do
      action = ->{ expose :thing, from: :foo, parent: :bar }
      expect(&action).to raise_error(ArgumentError, "Using :from option with other options doesn't make sense")
    end
  end
end
