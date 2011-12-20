require 'fixtures/foo_controller'

describe "DecentExposure integration" do
  describe "#expose" do
    let(:controller) { FooController.new }
    it "defines a method with the given name" do
      controller.should respond_to(:foo)
    end

    it "exposes the method to the view layer as a helper" do
      controller._helper_methods.should include(:foo)
    end

    it "prevents the method from being routable" do
      controller.hidden_actions.should include("foo")
    end

    it "caches the value, only loading once" do
      controller.class._exposures[:foo].should_receive(:call).once
      2.times { controller.foo }
    end
  end

  describe "block strategy" do
    it "uses the block to determine the value" do
      FooController.new.foo.should == "bar"
    end
  end
end
