require 'decent_exposure/active_record_with_eager_attributes_strategy'

describe DecentExposure::ActiveRecordWithEagerAttributesStrategy do
  describe "#resource" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model')
    end
    let(:model) { stub("Model", :new => nil) }
    let(:params) { Hash.new }
    let(:request) { stub(:get? => true) }
    let(:config) { stub(:options => {}) }
    let(:controller_class) { stub(:_decent_configurations => Hash.new(config)) }
    let(:controller) { stub(:params => params, :request => request, :class => controller_class) }
    let(:strategy) { DecentExposure::ActiveRecordWithEagerAttributesStrategy.new(controller, inflector) }

    subject { strategy.resource }

    context "with a found singular resource" do
      let(:plural) { false }
      context "with a put/post request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 2 }
        end
        let(:singular) { double("Resource") }
        let(:request) { stub(:get? => false) }
        it "sets the attributes from the request" do
          model.stub(:find => singular)
          singular.should_receive(:attributes=).with({"name" => "Timmy"})
          should == singular
        end
      end

      context "with a get request" do
        let(:params) do
          { "model" => { "name" => "Timmy" }, :id => 1 }
        end
        let(:singular) { double("Resource") }
        it "ignores the attributes" do
          model.stub(:find => singular)
          singular.should_not_receive(:attributes=)
          should == singular
        end
      end
    end

    context "with an unfindable singular resource" do
      let(:params) do
        { "model" => { "name" => "Timmy" } }
      end
      let(:plural) { false }
      let(:instance) { stub }
      it "it builds a new instance of the resource" do
        model.should_receive(:new).and_return(instance)
        instance.should_receive(:attributes=)
        should == instance
      end
    end

    context "with a collection resource" do
      let(:plural) { true }
      it "does not attempt to assign attributes" do
        scoped = stub
        model.should_receive(:scoped).and_return(scoped)
        scoped.should_not_receive(:attributes=)
        should == scoped
      end
    end
  end
end

