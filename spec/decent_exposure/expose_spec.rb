require 'decent_exposure/expose'
require 'action_controller'

class MyController < ActionController::Base
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }

  def params; end
end

RSpec.describe DecentExposure::Expose do

  describe ".expose" do
    let(:controller) { MyController.new }
    it "defines a getter and setter with the given name" do
      expect(controller).to respond_to(:bird)
      expect(controller).to respond_to(:"bird=")
    end

    it "exposes the getter to the view layer as a helper" do
      expect(controller._helper_methods).to include(:bird)
    end

    it "caches the value, only loading once" do
      expect(controller.class._exposures[:bird]).to receive(:call).once
      2.times { controller.bird }
    end

    it 'blacklists the @_resources instance variable' do
      expect(controller._protected_ivars).to include(:@_resources)
    end
  end

  describe ".expose!" do
    let(:controller) { MyController.new }
    let(:block) { lambda { "I'm a block" } }
    it "delegates to .expose" do
      expect(MyController).to receive(:expose).once
      MyController.expose!(:worm)
    end

    it "sets up a callback to evaluate the method in-controller" do
      expect(MyController).to receive(:set_callback).with(:process_action, :before, :worm)
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
      expect(ParentContoller._decent_configurations[:default].options).to eq(NonOverridingController._decent_configurations[:default].options)
    end

    it "does not override config for sibling classes" do
      expect(OverridingController._decent_configurations[:default].options).to_not eq(NonOverridingController._decent_configurations[:default].options)
    end
  end
end
