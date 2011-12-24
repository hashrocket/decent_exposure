require 'fixtures/controllers'
require 'rspec/rails'

describe BirdController, :type => :controller do

  describe "block strategy" do
    it "uses the block to determine the value" do
      get :show, :id => "something"
      controller.bird.should == "Bird"
    end
  end

end

describe DuckController, :type => :controller do

  describe "inheritance" do
    before { get :show }

    it "inherits exposures" do
      controller.ostrich.should == "Ostrich"
    end

    it "allows overriding exposures" do
      controller.bird.should == "Duck"
    end
  end

end

describe MallardController, :type => :controller do
  describe "deep inheritance" do
    it "allows inheritance several layers deep" do
      get :show
      controller.bird.should == "Duck"
      controller.ostrich.should == "Ostrich"
    end
  end
end
