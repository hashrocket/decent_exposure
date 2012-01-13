require 'decent_exposure/active_record'

describe DecentExposure::ActiveRecord do
  describe "#call" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model')
    end
    let(:model) { stub("Model") }
    let(:params) { Hash.new }
    let(:request) { stub(:get? => true) }
    let(:controller) { stub(:params => params, :request => request) }

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
        before { controller.stub(:models => scope) }
        it "scopes to that resource collection" do
          scope.should_receive(:find)
          strategy.call(controller)
        end
      end

      context "with a put/post request" do
        let(:params) do
          { "model" => { "name" => "Timmy" } }
        end
        let(:singular) { double("Resource") }
        let(:request) { stub(:get? => false) }
        it "sets the attributes from the request" do
          model.stub(:find => singular)
          singular.should_receive(:attributes=).with({"name" => "Timmy"})
          strategy.call(controller).should == singular
        end
      end

      context "with a get request" do
        let(:params) do
          { "model" => { "name" => "Timmy" } }
        end
        let(:singular) { double("Resource") }
        it "ignores the attributes" do
          model.stub(:find => singular)
          singular.should_not_receive(:attributes=)
          strategy.call(controller).should == singular
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
