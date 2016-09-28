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
end
