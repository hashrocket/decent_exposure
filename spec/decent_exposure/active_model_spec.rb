require 'decent_exposure/active_model'

describe DecentExposure::ActiveModel do
  describe "#call" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id", :plural? => plural)
    end
    let(:model) { stub("Model") }
    let(:params) { Hash.new }

    before do
      DecentExposure::Inflector.stub(:new => inflector)
    end

    context "with a singular resource" do
      let(:strategy) { DecentExposure::ActiveModel.new("model") }
      let(:instance) { stub }
      let(:plural) { false }

      context "with the request has an id param" do
        let(:params) { { :id => "7" } }
        it "finds the on the model using that id" do
          model.should_receive(:find).with("7").and_return(instance)
          strategy.call(params).should == instance
        end
      end

      context "with a request that has no id param, but has model_id param" do
        let(:params) { { "model_id" => "7" } }
        it "finds the on the model using model_id" do
          model.should_receive(:find).with("7").and_return(instance)
          strategy.call(params).should == instance
        end
      end
    end

    context "with a resource collection" do
      let(:plural) { true }
      let(:strategy) { DecentExposure::ActiveModel.new("models") }

      it "returns the scoped collection" do
        scoped = stub
        model.should_receive(:scoped).and_return(scoped)
        strategy.call(params).should == scoped
      end
    end
  end
end
