require 'helper'
require 'action_controller'
require 'decent_exposure/railtie'
DecentExposure::Railtie.insert

class Resource
  def self.scoped(opts); self; end
  def self.find(*args); end
  def initialize(*args); end
  attr_accessor :attributes
end

class Equipment
  def self.scoped(opts); self; end
  def self.find(*args); end
  def initialize(*args); end
end

describe "Rails' integration:", DecentExposure do
  let(:controller) { Class.new(ActionController::Base) }
  let(:instance) { controller.new }
  let(:request) { mock(:get? => true) }
  let(:params) { HashWithIndifferentAccess.new(:resource_id => 42) }

  before do
    controller.expose(:resource)
    instance.stubs(:request).returns(request)
  end

  context '.expose' do
    it 'is available to ActionController::Base' do
      ActionController::Base.should respond_to(:expose)
    end
  end

  context 'within descendant controllers' do
    let(:resource_controller) { Class.new(ActionController::Base) }
    let(:instance) { resource_controller.new }

    before do
      instance.stubs(:request).returns(request)
      instance.stubs(:params).returns(params)
      resource_controller.expose :resource
    end

    it 'inherits the default_exposure' do
      Resource.stubs(:find).returns('resource')
      instance.resource.should == 'resource'
    end

    it 'allows you to override the default_exposure' do
      resource_controller.class_eval do
        default_exposure {|name| name.to_s}
        expose :overridden
      end
      instance.overridden.should == 'overridden'
    end

    it 'does not override the default in ancestors' do
      Resource.stubs(:find).returns('preserved')
      instance.resource.should == 'preserved'
    end
  end

  context '.default_exposure' do
    before do
      instance.stubs(:params).returns(params)
    end

    it 'is available to ActionController::Base' do
      ActionController::Base.should respond_to(:default_exposure)
    end

    context 'for non-get requests' do
      let(:request) { mock(:get? => false) }
      let(:params) { HashWithIndifferentAccess.new(:id => 1, :resource => "unfiltered resource params") }
      before { Resource.stubs(:find).returns(Resource.new) }
      it 'updates attributes from params' do
        instance.resource.attributes.should == 'unfiltered resource params'
      end
      context do
        before do
          controller.class_eval do
            def resource_params
              'improved resource attributes'
            end
          end
        end
        it 'updates attributes from resource_params' do
          instance.resource.attributes.should == 'improved resource attributes'
        end
      end
    end

    context 'when no collection method exists' do
      it 'operates directly on the class' do
        Resource.should_receive(:find)
        instance.resource
      end
    end

    context 'when a collection method exists' do
      let(:controller){ Class.new(ActionController::Base) }
      let(:instance){ controller.new }

      before { class Person < Resource; end }

      context 'and the collection can be scoped' do
        let(:collection){ mock(:scoped => [self]) }

        before{ controller.expose(:person) }

        it 'uses the existing collection method' do
          instance.stubs(:people).returns(collection)
          collection.expects(:new)
          instance.person
        end
      end
      context 'when the collection can not be scoped' do
        let(:collection){ mock }

        before{ controller.expose(:person) }

        it 'falls back to the singularized constant' do
          instance.stubs(:people).returns(collection)
          Person.expects(:new)
          instance.person
        end
      end
    end

    context 'when either :resource_id or :id are present in params' do
      it "calls find with params[:resource_id] on the resource's class" do
        Resource.expects(:find).with(42)
        instance.resource
      end

      context 'when there is no :resource_id in params' do
        before { instance.stubs(:params).returns({:id => 73}) }

        it "calls find with params[:id] on the resource's class" do
          Resource.expects(:find).with(73)
          instance.resource
        end
      end
    end
    context 'when there are no ids in params' do
      before do
        instance.stubs(:params).returns({:resource => {:name => 'bob'}})
      end

      it 'calls new with params[:resouce_name]' do
        Resource.expects(:new).with({:name => 'bob'})
        instance.resource
      end
    end
  end
end
describe "Rails' integration:", DecentExposure do
  let(:controller) { Class.new(ActionController::Base) }
  let(:instance) { controller.new }
  let(:request) { mock(:get? => true) }
  let(:params) { HashWithIndifferentAccess.new(:resource_id => 42) }

  before do
    controller.expose(:equipment)
    instance.stubs(:request).returns(request)
    instance.stubs(:params).returns(params)
  end
  context 'when collection name is same as resource name' do
    it 'does not create a collection method' do
      instance.equipment
      instance.should respond_to(:equipment)
      instance.should_not respond_to(:equipments)
    end
  end
end
