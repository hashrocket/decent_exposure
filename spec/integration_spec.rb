require 'fixtures/controllers'

describe "DecentExposure integration" do

  describe "#expose" do
    let(:controller) { BirdController.new }
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
      controller.class._exposures[:bird].should_receive(:call).once
      2.times { controller.bird }
    end
  end

  describe "block strategy" do
    it "uses the block to determine the value" do
      BirdController.new.bird.should == "Bird"
    end
  end

  describe "inheritance" do
    let(:controller) { DuckController.new }

    it "inherits exposures" do
      controller.ostrich.should == "Ostrich"
    end

    it "allows overriding exposures" do
      controller.bird.should == "Duck"
    end

    it "leaves parent exposures unmolested" do
      controller.bird
      BirdController.new.bird.should == "Bird"
    end

    it "allows inheritance several layers deep" do
      mallard = MallardController.new
      mallard.bird.should == "Duck"
      mallard.ostrich.should == "Ostrich"
    end
  end

end
