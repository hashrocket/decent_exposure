require 'decent_exposure/expose'
require 'action_controller'

class MyController < ActionController::Base
  extend DecentExposure::Expose
  expose(:bird) { "Bird" }

  def params; end
end

describe DecentExposure::Expose do

  shared_examples ".expose" do
    let(:controller) { MyController.new }

    it "defines a method with the given name" do
      controller.should respond_to(:bird)
    end

    it "exposes the method to the view layer as a helper" do
      controller._helper_methods.should include(:bird)
    end

    it "prevents the method from being routable" do
      controller.hidden_actions.should include("bird")
    end

    it "caches the value, only loading once" do
      cached_method.should_receive(:call).once
      2.times { controller.bird }
    end
  end

  describe ".expose" do
    let(:controller) { MyController.new }
    let(:cached_method) { controller.class._exposures[:bird] }

    it_behaves_like ".expose"
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

  describe '#refine' do
    let(:controller) { MyController.new }

    it "responds to refine" do
      controller.should respond_to(:refine)
    end

    it "is not routable" do
      controller.hidden_actions.should include("refine")
    end

    it "yields the current value of the exposure" do
      controller.refine(:bird) {|val| val.should == "Bird" }
    end

    it "alters the exposed value" do
      controller.refine(:bird) { "Penguin" }
      controller.bird.should == "Penguin"
    end

    it "can be refined more than once" do
      10.times{|val| controller.refine(:bird) { val + 1 } }
      controller.bird.should == 10
    end

    describe "still behaves like .expose after being refined" do
      let(:block) { Proc.new {|val| val + " is the word" } }
      let(:cached_method) { block }

      before :each do
        controller.refine(:bird, &block)
      end

      it "is refined" do
        controller.bird.should == "Bird is the word"
      end

      it_behaves_like ".expose"
    end
  end
end
