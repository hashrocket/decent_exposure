require 'action_controller'
require File.join(File.dirname(__FILE__), '..', 'helper')
require File.join(File.dirname(__FILE__), '..', '..', 'rails', 'init.rb')

class Quacker
  extend DecentExposure
  def self.helper_method(*args); end
  def self.hide_action(*args); end
  def memoizable(*args); args; end
  expose(:proxy)
end

ActionController::Base.class_eval do
  def params; {'resource_id' => 42}; end
end

class ResourceController < ActionController::Base; end

class Resource; end

describe DecentExposure do
  context "classes extending DecentExposure" do
    it "respond to :expose" do
      Quacker.respond_to?(:expose).should be_true
    end
  end

  context "#expose" do
    let(:instance){ Quacker.new }

    it "creates a method with the given name" do
      Quacker.new.methods.map{|m| m.to_s}.should include('proxy')
    end

    it "prevents the method from being a callable action" do
      Quacker.expects(:hide_action).with(:blerg)
      Quacker.class_eval do
        expose(:blerg){ 'ehm' }
      end
    end

    it "declares the method as a helper method" do
      Quacker.stubs(:hide_action)
      Quacker.expects(:helper_method).with(:blarg)
      Quacker.class_eval do
        expose(:blarg){ 'uhm' }
      end
    end

    it "returns the result of the exposed block from the method" do
      Quacker.stubs(:hide_action)
      Quacker.stubs(:helper_method)
      Quacker.class_eval do
        expose(:quack){ memoizable('quack!') }
      end
      instance.quack.should == %w(quack!)
    end

    it "memoizes the value of the created method" do
      instance.expects(:memoizable).once.returns('value')
      instance.quack
      instance.quack
    end

    context "customizing the default exposure" do
      it "uses the given default_exposure" do
        ResourceController.class_eval do
          default_exposure { 'default value' }
          expose :resource
        end
        ResourceController.new.resource.should == "default value"
      end

      it "uses arguments that are passed to the default_exposure" do
        ResourceController.class_eval do
          default_exposure {|name| "many #{name}"}
          expose :resources
        end
        ResourceController.new.resources.should == "many resources"
      end
    end
  end

  context "within Rails" do
    let(:controller) { ActionController::Base.new }

    it "extends ActionController::Base" do
      ActionController::Base.respond_to?(:expose).should == true
    end

    context "by default" do
      it "calls find with params[:resource_id] on the resource's class" do
        Resource.expects(:find).with(42)
        ActionController::Base.class_eval do
          expose 'resource'
        end
        controller.resource
      end
      context "or, when there is no :resource_id in params" do
        before do
          ActionController::Base.class_eval do
            def params; {'id' => 24}; end
          end
        end
        it "calls find with params[:id] on the resource's class" do
          Resource.expects(:find).with(24)
          controller.resource
        end
      end
    end

    context "within descendant controllers" do
      let(:my_controller) {ResourceController.new}

      it "inherits the default exposure" do
        ResourceController.class_eval { expose :resources }
        my_controller.resources.should == 'many resources'
      end

      it "allows overridden default in descendant controllers" do
        ResourceController.class_eval do
          default_exposure {|name| name.to_s}
          expose :overridden
        end
        my_controller.overridden.should == 'overridden'
      end

      it "preserves default in ancestors" do
        Resource.stubs(:find).returns('preserved')
        ActionController::Base.class_eval do
          expose :resource
        end
        controller.resource.should == 'preserved'
      end
    end
  end
end
