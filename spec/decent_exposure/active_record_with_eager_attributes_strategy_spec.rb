require 'decent_exposure/active_record_with_eager_attributes_strategy'

describe DecentExposure::ActiveRecordWithEagerAttributesStrategy do
  describe "#resource" do
    let(:inflector) do
      double("Inflector", :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model', :param_key => 'model')
    end
    let(:model) { double("Model", :new => nil) }
    let(:params) { Hash.new }
    let(:request) { double(:post? => false, :patch? => false, :put? => false) }
    let(:config) { double(:options => {}) }
    let(:controller_class) { double(:_decent_configurations => Hash.new(config)) }
    let(:controller) { double(:params => params, :request => request, :class => controller_class) }
    let(:strategy) { DecentExposure::ActiveRecordWithEagerAttributesStrategy.new(controller, inflector) }

    subject { strategy.resource }

    before do
      strategy.model = model
      strategy.inflector = inflector
    end

    context "with a found singular resource" do
      let(:plural) { false }
      context "with a get request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 1 }
        end
        let(:singular) { double("Resource") }
        it "ignores the attributes" do
          allow(model).to receive_messages(:find => singular)
          expect(singular).not_to receive(:attributes=)
          is_expected.to eq(singular)
        end
      end

      context "with a post request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 2 }
        end
        let(:singular) { double("Resource") }
        before do
          allow(request).to receive_messages(:post? => true)
        end
        it "sets the attributes from the request" do
          allow(model).to receive_messages(:find => singular)
          expect(singular).to receive(:attributes=).with({"name" => "Timmy"})
          is_expected.to eq(singular)
        end
      end

      context "with a put request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 2 }
        end
        let(:singular) { double("Resource") }
        before do
          allow(request).to receive_messages(:put? => true)
        end
        it "sets the attributes from the request" do
          allow(model).to receive_messages(:find => singular)
          expect(singular).to receive(:attributes=).with({"name" => "Timmy"})
          is_expected.to eq(singular)
        end
      end

      context "with a delete request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 1 }
        end
        let(:singular) { double("Resource") }
        before do
          allow(request).to receive_messages(:delete? => true)
        end
        it "ignores the attributes" do
          allow(model).to receive_messages(:find => singular)
          expect(singular).not_to receive(:attributes=)
          is_expected.to eq(singular)
        end
      end
    end

    context "when the params for the resource is nil" do
      let(:params) { {} }
      let(:instance) { double }
      let(:plural) { false }

      it "sends a empty hash to attributes=" do
        expect(model).to receive(:new).and_return(instance)
        expect(instance).to receive(:attributes=).with({})
        is_expected.to eq(instance)
      end
    end

    context "with an unfindable singular resource" do
      let(:params) do
        { "model" => { "name" => "Timmy" } }
      end
      let(:plural) { false }
      let(:instance) { double }
      it "it builds a new instance of the resource" do
        expect(model).to receive(:new).and_return(instance)
        expect(instance).to receive(:attributes=)
        is_expected.to eq(instance)
      end
    end

    context "with a collection resource" do
      let(:plural) { true }
      before { stub_const("ActiveRecord::VERSION::MAJOR", 3) }
      it "does not attempt to assign attributes" do
        scoped = double
        expect(model).to receive(:scoped).and_return(scoped)
        expect(scoped).not_to receive(:attributes=)
        is_expected.to eq(scoped)
      end
    end
  end
end

