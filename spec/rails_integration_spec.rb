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

  describe "attribute setting" do
    let(:request) { [:show, { :parrot => { :beak => "droopy" } }] }
    it "attributes are set for post requests" do
      post *request
      controller.parrot.beak.should == "droopy"
    end

    it "attributes are set for put requests" do
      put *request
      controller.parrot.beak.should == "droopy"
    end

    it "attributes are ignored on get requests" do
      get *request
      controller.parrot.beak.should_not == "droopy"
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

describe DefaultExposureController, :type => :controller do
  describe 'default exposure' do
    it 'is used by blockless expose calls' do
      controller.dodo.should == 'DODO'
    end
    it 'is not used by expose calls with blocks' do
      controller.penguin.should == 'Happy Feet'
    end
  end
end

describe ChildDefaultExposureController, :type => :controller do
  describe 'default exposure inheritance' do
    it 'uses the parent default exposure' do
      controller.eagle.should == 'EAGLE'
    end
  end
end

describe OverridingChildDefaultExposureController, :type => :controller do
  describe 'default exposure inheritance' do
    it 'can be overridden' do
      controller.penguin.should == 'niugnep'
    end
  end
end
