require "spec_helper"
require "support/rails_app"
require "rspec/rails"

class Bird
  attr_accessor :name
  def initialize(options = {})
    options.each do |k,v|
      self.public_send("#{k}=", v)
    end
  end
end

class BirdsController < ApplicationController
end

describe BirdsController, type: :controller do
  let(:bird){ Bird.new }

  context 'when a bird is exposed' do
    class BirdsController < ApplicationController
      expose :bird

      def show
        head :ok
      end
    end

    it "finds model by id" do
      expect(Bird).to receive(:find).with("bird-id").once.and_return(bird)
      get :show, request_params(id: "bird-id")
      expect(controller.bird).to eq(bird)
    end

    it "finds model by bird_id" do
      expect(Bird).to receive(:find).with("bird-id").once.and_return(bird)
      get :show, request_params(bird_id: "bird-id")
      expect(controller.bird).to eq(bird)
    end

    it "builds bird if id is not provided" do
      get :show
      expect(controller.bird).to be_a(Bird)
    end
  end

  context 'when a bird? with a question mark is exposed' do
    class BirdsController < ApplicationController
      expose :bird
      expose :bird?, -> { bird.present? }

      def show
        head :ok
      end
    end

    it "exposes bird?" do
      expect(Bird).to receive(:find).with("bird-id").once.and_return(bird)
      get :show, request_params(bird_id: "bird-id")
      expect(controller.bird?).to be true
    end
  end
end
