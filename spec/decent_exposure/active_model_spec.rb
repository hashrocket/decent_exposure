require 'decent_exposure/active_model'

describe DecentExposure::ActiveModel do
  describe "#call" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id")
    end
    let(:model) { stub("Model") }
    let(:strategy) { DecentExposure::ActiveModel.new("model") }

    before do
      DecentExposure::Inflector.stub(:new => inflector)
    end

    context "with the request has an id param" do
      let(:params) { { :id => "7" } }
      it "finds the on the model using that id" do
        model.should_receive(:find).with("7")
        strategy.call(params)
      end
    end

    context "with a request that has no id param, but has model_id param" do
      let(:params) { { "model_id" => "7" } }
      it "finds the on the model using model_id" do
        model.should_receive(:find).with("7")
        strategy.call(params)
      end
    end
  end
end
