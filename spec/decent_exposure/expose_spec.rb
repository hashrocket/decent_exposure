require 'decent_exposure/expose'
require 'action_controller'

class MyController < ActionController::Base
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }

  def params; end
end

describe DecentExposure::Expose do

  describe ".expose" do
    let(:controller) { MyController.new }
    it "defines a getter and setter with the given name" do
      controller.should respond_to(:bird)
      controller.should respond_to(:"bird=")
    end

    it "exposes the getter to the view layer as a helper" do
      controller._helper_methods.should include(:bird)
    end

    it "prevents the getter and setter methods from being routable" do
      controller.hidden_actions.should include("bird")
      controller.hidden_actions.should include("bird=")
    end

    it "caches the value, only loading once" do
      controller.class._exposures[:bird].should_receive(:call).once
      2.times { controller.bird }
    end

    it 'blacklists the @_resources instance variable' do
      controller.class.protected_instance_variables.should include("@_resources")
    end
  end

  describe ".expose!" do
    let(:controller) { MyController.new }
    let(:block) { lambda { "I'm a block" } }
    it "delegates to .expose" do
      MyController.should_receive(:expose).once
      MyController.expose!(:worm)
    end

    it "sets up a callback to evaluate the method in-controller" do
      MyController.should_receive(:set_callback).with(:process_action, :before, :worm)
      MyController.expose!(:worm)
    end
  end

  describe ".decent_configuration" do
    class ParentContoller < ActionController::Base
      extend DecentExposure::Expose
      decent_configuration do
        finder :find
      end
    end

    class NonOverridingController < ParentContoller
    end

    class OverridingController < ParentContoller
      decent_configuration do
        finder :overridden
      end
    end

    it "inherits from superclasses" do
      ParentContoller._decent_configurations[:default].options.should == NonOverridingController._decent_configurations[:default].options
    end

    it "does not override config for sibling classes" do
      OverridingController._decent_configurations[:default].options.should_not == NonOverridingController._decent_configurations[:default].options
    end
  end
end
