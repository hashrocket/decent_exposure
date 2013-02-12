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

    context "with a named model" do
      it "finds an instance" do
        get :show, :id => "something"
        controller.albert.should be_a Parrot
      end
    end

    context "with a namespaced model class" do
      it "finds an instance" do
        get :show, :id => "something"
        controller.bernard.beak.should == 'admin'
      end

      it "assigns based on unnamespaced parameter" do
        post :show, :parrot => { :beak => 'bent' }
        controller.bernard.beak.should == 'bent'
      end
    end
  end

  describe "attribute setting" do
    let(:request) { [:show, { :id => 2, :parrot => { :beak => "droopy" } }] }
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

    context "with no finding parameter" do
      it "builds a new model instance with the provided attributes" do
        get :new, :parrot => { :beak => "smallish" }
        controller.parrot.beak.should == "smallish"
      end

      it "builds a new model without attributes" do
        get :new
        controller.parrot.beak.should be_nil
      end
    end
  end

  describe "setter method for overriding" do
    it "sets the exposure to the provided object" do
      get :index
      controller.bird.should be_a Parrot
    end
  end

  describe "custom strategy classes" do
    it "initializes classes with name, calls them with call" do
      get :show
      controller.custom.should == 'customshow'
    end

    it "works with decent_configuration" do
      get :show
      controller.custom_from_config.should == "custom_from_configshow"
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

    it "inherits decent configurations" do
      controller.custom_from_config.should == "custom_from_configshow"
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

describe StrongParametersController, :type => :controller do
  describe "attribute setting" do

    context "with an 'attributes' option set" do
      let(:request) { [:show, { :id => 2, :assignable => { :beak => "droopy" } }] }
      it "assigns attributes for post requests, using the method from 'attributes'" do
        post *request
        controller.assignable.beak.should == "droopy"
      end

      it "assigns attributes for post requests, using the method from 'attributes'" do
        put *request
        controller.assignable.beak.should == "droopy"
      end

      it "does not assign attributes on get requests" do
        get *request
        controller.assignable.beak.should_not == "droopy"
      end
    end

    context "with no 'attributes' option set" do
      let(:request) { [:show, { :id => 2, :unassignable => { :beak => "droopy" } }] }
      it "does not assign attributes" do
        post *request
        controller.assignable.beak.should_not == "droopy"
      end
    end
  end
end

describe TaxonomiesController, :type => :controller do
  describe 'default configration' do
    it 'uses the configured finder' do
      get :show, :id => "something"
      controller.organism.should be_a(Organism)
    end
  end
  describe 'named configration' do
    it "uses the named configuration's options" do
      get :show, :id => "something"
      controller.owl.species.should eq('Striginae')
    end
  end
end

describe Namespace::ModelController, :type => :controller do
  it "finds the instance of the namespaced model" do
    get :show, :id => "foo"
    controller.model.name.should == "inner"
  end
end
