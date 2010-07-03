require 'helper'
require 'action_controller'

require File.join(File.dirname(__FILE__), '..', '..', 'rails', 'init.rb')

ActionController::Base.class_eval do
  def params; HashWithIndifferentAccess.new(:resource_id => 42); end
  expose :resource
end

class Resource
  def self.scoped(opts); Resource; end
  def self.find(*args); end
  def initialize(*args); end
end

describe "Rails' integration:", DecentExposure do
  let(:controller) { ActionController::Base.new }
  let(:request) { mock(:get? => true) }
  before { controller.stubs(:request).returns(request) }

  it 'extends ActionController::Base' do
    ActionController::Base.should respond_to(:expose)
  end

  context '.default_exposure' do
    context 'when no collection method exists' do
      it 'creates a collection method to scope from' do
        controller.resource
        controller.methods.should include('resources')
      end
    end
    context 'when a collection method exists' do
      before do
        def controller.resources; end
      end
      it 'uses the existing collection method' do
        controller.expects(:resources).returns(Resource)
        controller.resource
      end
    end

    context 'when either :resource_id or :id are present in params' do
      it "calls find with params[:resource_id] on the resource's class" do
        Resource.expects(:find).with(42)
        controller.resource
      end

      context 'when there is no :resource_id in params' do
        before do
          def controller.params; {:id => 73}; end
        end

        it "calls find with params[:id] on the resource's class" do
          Resource.expects(:find).with(73)
          controller.resource
        end
      end
    end
    context 'when there are no ids in params' do
      before do
        def controller.params; {:resource => {:name => 'bob'}} end
      end
      it 'calls new with params[:resouce_name]' do
        Resource.expects(:new).with({:name => 'bob'})
        controller.resource
      end
    end
  end

  context 'within descendant controllers' do
    let(:resource_controller) { Class.new(ActionController::Base) }
    let(:instance) { resource_controller.new }
    before do
      instance.stubs(:request).returns(request)
      def instance.params; HashWithIndifferentAccess.new(:resource_id => 42); end
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
      controller.resource.should == 'preserved'
    end
  end
end
