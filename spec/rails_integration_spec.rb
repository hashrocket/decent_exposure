require 'fixtures/controllers'
require 'rspec/rails'

describe BirdController, :type => :controller do

  describe "block strategy" do
    it "uses the block to determine the value" do
      get :show
      controller.bird.should == "Bird"
    end
  end

  describe "default model strategy" do
    it "finds the instance with params[:id]" do
      get :show, :id => "something"
      controller.parrot.should be_a Parrot
    end

    it "finds the instance with params[:model_id]" do
      get :show, :parrot_id => "something"
      controller.parrot.should be_a Parrot
    end

    it "finds a collection" do
      get :show
      controller.albatrosses.should have(2).albatrosses
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

  describe "collection scope" do
    it "scopes a resource to its collection exposure" do
      get :show, :id => "burp"
      controller.duck.id.should == "burp"
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
