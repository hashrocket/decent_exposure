require "spec_helper"
require "support/rails_app"
require "rspec/rails"

describe BirdsController, type: :controller do
  context "finds bird by id" do
    let(:mockingbird){ double("Bird") }
    before{ expect(Bird).to receive(:find).with("mockingbird").once.and_return(mockingbird) }
    after{ expect(controller.bird).to eq(mockingbird) }

    it "finds model by id" do
      get :show, { id: "mockingbird" }
    end

    it "finds model by bird_id" do
      get :show, { bird_id: "mockingbird" }
    end
  end

  it "builds bird if id is not provided" do
    bird = double("Bird")
    expect(Bird).to receive(:new).with({}).and_return(bird)
    get :show
    expect(controller.bird).to eq(bird)
  end
end
