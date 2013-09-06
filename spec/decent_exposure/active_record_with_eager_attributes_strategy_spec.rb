require 'decent_exposure/active_record_with_eager_attributes_strategy'

describe DecentExposure::ActiveRecordWithEagerAttributesStrategy do
  describe "#resource" do
    let(:inflector) do
      double("Inflector", :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model', :param_key => 'model')
    end
    let(:model) { double("Model", :new => nil) }
    let(:params) { Hash.new }
    let(:request) { double(:get? => true) }
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
        let(:request) { double("Request") }
        before do
          request.stub(:get?    => true)
          request.stub(:delete? => false)
        end
        it "ignores the attributes" do
          model.stub(:find => singular)
          singular.should_not_receive(:attributes=)
          should == singular
        end
      end

      context "with a post request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 2 }
        end
        let(:singular) { double("Resource") }
        let(:request) { double("Request") }
        before do
          request.stub(:get?    => false)
          request.stub(:delete? => false)
        end
        it "sets the attributes from the request" do
          model.stub(:find => singular)
          singular.should_receive(:attributes=).with({"name" => "Timmy"})
          should == singular
        end
      end

      context "with a put request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 2 }
        end
        let(:singular) { double("Resource") }
        let(:request) { double("Request") }
        before do
          request.stub(:get?    => false)
          request.stub(:delete? => false)
        end
        it "sets the attributes from the request" do
          model.stub(:find => singular)
          singular.should_receive(:attributes=).with({"name" => "Timmy"})
          should == singular
        end
      end

      context "with a delete request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 1 }
        end
        let(:singular) { double("Resource") }
        let(:request) { double("Request") }
        before do
          request.stub(:get?    => false)
          request.stub(:delete? => true)
        end
        it "ignores the attributes" do
          model.stub(:find => singular)
          singular.should_not_receive(:attributes=)
          should == singular
        end
      end
    end

    context "when the params for the resource is nil" do
      let(:params) { {} }
      let(:instance) { double }
      let(:plural) { false }

      it "sends a empty hash to attributes=" do
        model.should_receive(:new).and_return(instance)
        instance.should_receive(:attributes=).with({})
        should == instance
      end
    end

    context "with an unfindable singular resource" do
      let(:params) do
        { "model" => { "name" => "Timmy" } }
      end
      let(:plural) { false }
      let(:instance) { double }
      it "it builds a new instance of the resource" do
        model.should_receive(:new).and_return(instance)
        instance.should_receive(:attributes=)
        should == instance
      end
    end

    context "with a collection resource" do
      let(:plural) { true }
      before { stub_const("ActiveRecord::VERSION::MAJOR", 3) }
      it "does not attempt to assign attributes" do
        scoped = double
        model.should_receive(:scoped).and_return(scoped)
        scoped.should_not_receive(:attributes=)
        should == scoped
      end
    end
  end
end

