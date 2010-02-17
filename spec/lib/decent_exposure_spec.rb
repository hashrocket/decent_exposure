require File.join(File.dirname(__FILE__), '..', 'helper')

class Quacker
  extend DecentExposure
  def self.helper_method(*args); end
  def self.hide_action(*args); end
  def memoizable(*args); args; end
  expose(:proxy)
end

module ActionController
  class Base
    def self.helper_method(*args); end
    def self.hide_action(*args); end
    def params; {'resource_id' => 42}; end
  end
end
require File.join(File.dirname(__FILE__), '..', '..', 'rails', 'init.rb')

class MyController < ActionController::Base
end

class Resource
  def self.find(*args); end
end

class Widget
  def self.find(*args); end
end

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

    context "when specifying custom default behavior" do
      before(:all) do
        class ::DuckController
          extend DecentExposure
          def self.helper_method(*args); end
          def self.hide_action(*args); end
          def params; end
          default_exposure {"default value"}
          expose(:quack)
        end
      end

      it "uses that behavior when no block is given" do
        DuckController.new.quack.should == "default value"
      end

      it "passes the name given to #expose into the block" do
        DuckController.class_eval do
          default_exposure {|name| "downy #{name}"}
          expose :feathers
        end
        DuckController.new.feathers.should == "downy feathers"
      end
    end
  end

  context "within Rails" do
    let(:controller) {ActionController::Base.new}

    let(:resource){ 'resource' }
    let(:resource_class_name){ 'Resource' }
    before do
      resource.stubs(:to_s => resource, :classify => resource_class_name)
      resource_class_name.stubs(:constantize => Resource)
    end

    it "extends ActionController::Base" do
      ActionController::Base.respond_to?(:expose).should == true
    end

    context "by default" do
      it "calls find with params[:resource_id] on the resource's class" do
        name = resource
        Resource.expects(:find).with(42)
        ActionController::Base.class_eval do
          expose name
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

    let(:widget){ 'widget' }
    let(:widget_class_name){ 'Widget' }
    before do
      widget.stubs(:to_s => widget, :classify => widget_class_name)
      widget_class_name.stubs(:constantize => Widget)
    end

    let(:my_controller) {MyController.new}

    it "works in descendant controllers" do
      name = widget
      Widget.expects(:find).with(123).returns('a widget')
      MyController.class_eval do
        def params; {'id' => 123} end
        expose name
      end

      my_controller.widget.should == 'a widget'
    end

    it "allows overridden default in descendant controllers" do
      MyController.class_eval do
        default_exposure {|name| name.to_s}
        expose :overridden
      end
      my_controller.overridden.should == 'overridden'
    end

    it "preserves default in ancestors" do
      name = widget
      Widget.stubs(:find).returns('preserved')
      ActionController::Base.class_eval do
        expose name
      end
      controller.widget.should == 'preserved'
    end
  end
end
