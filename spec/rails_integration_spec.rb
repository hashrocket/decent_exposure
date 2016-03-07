require "fixtures/controllers"
require "rspec/rails"

RSpec.describe BirdController, type: :controller do
  describe "block strategy" do
    it "uses the block to determine the value" do
      get :show
      expect(controller.bird).to eq("Bird")
    end
  end

  describe "default model strategy" do
    it "finds the instance with params[:id]" do
      get :show, { id: "something" }
      expect(controller.parrot).to be_a(Parrot)
    end

    it "finds the instance with params[:model_id]" do
      get :show, {parrot_id: "something"}
      expect(controller.parrot).to be_a(Parrot)
    end

    it "finds a collection" do
      get :show
      expect(controller.albatrosses.size).to eq(2)
    end

    context "with a named model" do
      it "finds an instance" do
        get :show, { id: "something" }
        expect(controller.albert).to be_a(Parrot)
      end
    end

    context "with a namespaced model class" do
      it "finds an instance" do
        get :show, { id: "something" }
        expect(controller.bernard.beak).to eq("admin")
      end

      it "assigns based on model's param key" do
        post :show, { admin_parrot: { beak: "bent" } }
        expect(controller.bernard.beak).to eq("bent")
      end
    end
  end

  describe "attribute setting" do
    let(:request) { [:show, { id: 2, parrot: { beak: "droopy" } }] }
    it "attributes are set for post requests" do
      post *request
      expect(controller.parrot.beak).to eq("droopy")
    end

    it "attributes are set for put requests" do
      put *request
      expect(controller.parrot.beak).to eq("droopy")
    end

    it "attributes are ignored on get requests" do
      get *request
      expect(controller.parrot.beak).to_not eq("droopy")
    end

    context "with no finding parameter" do
      it "builds a new model instance with the provided attributes" do
        get :new, { parrot: { beak: "smallish" } }
        expect(controller.parrot.beak).to eq("smallish")
      end

      it "builds a new model without attributes" do
        get :new
        expect(controller.parrot.beak).to be_nil
      end
    end
  end

  describe "setter method for overriding" do
    it "sets the exposure to the provided object" do
      get :index
      expect(controller.bird).to be_a(Parrot)
    end
  end

  describe "custom strategy classes" do
    it "initializes classes with name, calls them with call" do
      get :show
      expect(controller.custom).to eq("customshow")
    end

    it "works with decent_configuration" do
      get :show
      expect(controller.custom_from_config).to eq("custom_from_configshow")
    end
  end

  describe "collection with plural name and model" do
    it "scopes the resource to the collection" do
      get :index
      controller.organisms.each do |organism|
        expect(organism).to be_an(Organism)
      end
    end
  end
end

RSpec.describe DuckController, type: :controller do
  describe "inheritance" do
    before { get :show }

    it "inherits exposures" do
      expect(controller.ostrich).to eq("Ostrich")
    end

    it "allows overriding exposures" do
      expect(controller.bird).to eq("Duck")
    end

    it "inherits decent configurations" do
      expect(controller.custom_from_config).to eq("custom_from_configshow")
    end
  end

  describe "collection scope" do
    it "scopes a resource to its collection exposure" do
      get :show, { id: "burp" }
      expect(controller.duck.id).to eq("burp")
    end
  end
end

RSpec.describe MallardController, type: :controller do
  describe "deep inheritance" do
    it "allows inheritance several layers deep" do
      get :show
      expect(controller.bird).to eq("Duck")
      expect(controller.ostrich).to eq("Ostrich")
    end
  end
end

RSpec.describe StrongParametersController, type: :controller do
  describe "attribute setting" do
    context "with an 'attributes' option set" do
      let(:request) { [:show, { id: 2, assignable: { beak: "droopy" } }] }
      it "assigns attributes for post requests, using the method from 'attributes'" do
        post *request
        expect(controller.assignable.beak).to eq("droopy")
      end

      it "assigns attributes for post requests, using the method from 'attributes'" do
        put *request
        expect(controller.assignable.beak).to eq("droopy")
      end

      it "does not assign attributes on get requests" do
        get *request
        expect(controller.assignable.beak).to_not eq("droopy")
      end

      it "does not assign attributes for HEAD requests" do
        head *request
        expect(controller.assignable.beak).to_not eq("droopy")
      end
    end

    context "with no 'attributes' option set" do
      let(:request) { [:show, { id: 2, unassignable: { beak: "droopy" } }] }
      it "does not assign attributes" do
        post *request
        expect(controller.assignable.beak).to_not eq("droopy")
      end
    end
  end
end

RSpec.describe TaxonomiesController, type: :controller do
  describe 'default configration' do
    it 'uses the configured finder' do
      get :show, { id: "something" }
      expect(controller.organism).to be_a(Organism)
    end
  end

  describe 'named configration' do
    it "uses the named configuration's options" do
      get :show, { id: "something" }
      expect(controller.owl.species).to eq("Striginae")
    end
  end
end

RSpec.describe Namespace::ModelController, type: :controller do
  it "finds the instance of the namespaced model" do
    get :show, { id: "foo" }
    expect(controller.model.name).to eq("inner")
  end
end
