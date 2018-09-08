require "spec_helper"
require "support/rails_app"
require "rspec/rails"

RSpec.describe BirdsController, type: :controller do
  let(:bird){ Bird.new }

  context 'when birds relation is exposed' do
    class BirdsController
      expose :birds, ->{ Bird.all }
    end

    it "fetches all birds" do
      expect(Bird).to receive(:all).and_return([bird])
      get :index
      expect(controller.birds).to eq([bird])
    end
  end

  context 'when a bird is exposed' do
    class BirdsController
      expose :bird
    end

    it "finds model by id" do
      expect(Bird).to receive(:find).with("bird-id").and_return(bird)
      get :show, request_params(id: "bird-id")
      expect(controller.bird).to eq(bird)
    end

    it "finds model by bird_id" do
      expect(Bird).to receive(:find).with("bird-id").and_return(bird)
      get :new, request_params(bird_id: "bird-id")
      expect(controller.bird).to eq(bird)
    end

    it "builds bird if id is not provided" do
      get :new
      expect(controller.bird).to be_a(Bird)
    end
  end

  context "when bird_params is defined" do
    class BirdsController
      expose :bird

      def bird_params
        params.require(:bird).permit(:name)
      end
    end

    it "bird is build with params set" do
      post :create, request_params(bird: { name: "crow" })
      expect(controller.bird.name).to eq("crow")
    end
  end

  context 'when a bird? with a question mark is exposed' do
    class BirdsController
      expose :bird
      expose :bird?, -> { bird.present? }
    end

    it "exposes bird?" do
      expect(Bird).to receive(:find).with("bird-id").and_return(bird)
      get :show, request_params(id: "bird-id")
      expect(controller.bird?).to be true
    end
  end

  context "when egg depends on bird being linked" do
    class BirdsController
      expose :bird
      expose :egg, parent: :bird

      def egg_params
        params.require(:egg).permit(:name)
      end
    end

    it "builds egg through bird with a name that depends on bird's species" do
      post :create, request_params(bird: { name: 'Bob' }, egg: { name: 'Bill' })
      expect(controller.egg.name).to eq("Bill (Kiwi)")
    end
  end
end

RSpec.describe EggsController, type: :controller do
  context "when egg is loaded standalone" do
    class EggsController
      expose :egg

      def egg_params
        params.require(:egg).permit(:name)
      end
    end

    it "builds egg with name that includes default type" do
      post :create, request_params(egg: { name: 'Barry' })
      expect(controller.egg.name).to eq("Barry (Fantail)")
    end
  end
end
