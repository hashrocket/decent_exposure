require "spec_helper"
require "support/rails_app"
require "rspec/rails"

describe BirdsController, type: :controller do
  context "finds bird by id" do
    let(:mockingbird){ double("Bird") }

    it "finds model by id" do
      expect(Bird).to receive(:find).with("mockingbird").once.and_return(mockingbird)
      get :show, id: "mockingbird"
      expect(controller.bird).to eq(mockingbird)
    end

    it "finds model by bird_id" do
      expect(Bird).to receive(:find).with("mockingbird").once.and_return(mockingbird)
      get :show, bird_id: "mockingbird"
      expect(controller.bird).to eq(mockingbird)
    end

    it "exposes bird?" do
      expect(Bird).to receive(:find).with("mockingbird").once.and_return(mockingbird)
      get :show, { bird_id: "mockingbird" }
      expect(controller.bird?).to be true
    end
  end

  it "builds bird if id is not provided" do
    bird = double("Bird")
    expect(Bird).to receive(:new).with({}).and_return(bird)
    get :show
    expect(controller.bird).to eq(bird)
  end
end
