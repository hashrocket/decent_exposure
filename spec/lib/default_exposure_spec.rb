require 'helper'
require 'action_controller'

require File.join(File.dirname(__FILE__), '..', '..', 'rails', 'init.rb')

class Resource; end

ActionController::Base.class_eval do
  def params; {'resource_id' => 42}; end
  expose :resource
end

describe "Rails' integration:", DecentExposure do
  let(:controller) { ActionController::Base.new }

  it 'extends ActionController::Base' do
    ActionController::Base.should respond_to(:expose)
  end

  context '.default_exposure' do
    it "calls find with params[:resource_id] on the resource's class" do
      Resource.expects(:find).with(42)
      controller.resource
    end

    context 'when there is no :resource_id in params' do
      before do
        ActionController::Base.class_eval do
          def params; {'id' => 73}; end
        end
      end

      it "calls find with params[:id] on the resource's class" do
        Resource.expects(:find).with(73)
        controller.resource
      end
    end
  end

  context 'within descendant controllers' do
    class ResourceController < ActionController::Base; end

    let(:my_controller) { ResourceController.new }

    it 'inherits the default_exposure' do
      Resource.stubs(:find).returns('resource')
      my_controller.resource.should == 'resource'
    end

    it 'allows you to override the default_exposure' do
      ResourceController.class_eval do
        default_exposure {|name| name.to_s}
        expose :overridden
      end
      my_controller.overridden.should == 'overridden'
    end

    it 'does not override the default in ancestors' do
      Resource.stubs(:find).returns('preserved')
      controller.resource.should == 'preserved'
    end
  end
end
