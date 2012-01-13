require 'decent_exposure/active_record'

describe DecentExposure::ActiveRecord do
  describe "#call" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id", :plural? => plural, :plural => 'models')
    end
    let(:model) { stub("Model") }
    let(:params) { Hash.new }
    let(:controller) { stub(:params => params) }

    before do
      DecentExposure::Inflector.stub(:new => inflector)
    end

    context "with a singular resource" do
      let(:strategy) { DecentExposure::ActiveRecord.new("model") }
      let(:instance) { stub }
      let(:plural) { false }

      context "with the request has an id param" do
        let(:params) { { :id => "7" } }
        it "finds the on the model using that id" do
          model.should_receive(:find).with("7").and_return(instance)
          strategy.call(controller).should == instance
        end
      end

      context "with a request that has no id param, but has model_id param" do
        let(:params) { { "model_id" => "7" } }
        it "finds the on the model using model_id" do
          model.should_receive(:find).with("7").and_return(instance)
          strategy.call(controller).should == instance
        end
      end

      context "with a corresponding resource collection exposure defined" do
        let(:scope) { double("Models") }
        before { controller.stub(:methods => [:models], :models => scope) }
        it "scopes to that resource collection" do
          scope.should_receive(:find)
          strategy.call(controller)
        end
      end

    end

    context "with a resource collection" do
      let(:plural) { true }
      let(:strategy) { DecentExposure::ActiveRecord.new("models") }

      it "returns the scoped collection" do
        scoped = stub
        model.should_receive(:scoped).and_return(scoped)
        strategy.call(controller).should == scoped
      end
    end
  end
end
