require 'decent_exposure/active_record_strategy'

describe DecentExposure::ActiveRecordStrategy do
  describe "#resource" do
    let(:inflector) do
      double("Inflector", :constant => model, :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model')
    end
    let(:model) { stub("Model", :new => nil) }
    let(:params) { Hash.new }
    let(:request) { stub(:get? => true) }
    let(:controller) { stub(:params => params, :request => request) }
    let(:strategy) { DecentExposure::ActiveRecordStrategy.new(controller, inflector) }

    subject { strategy.resource }

    context "with a singular resource" do
      let(:instance) { stub }
      let(:plural) { false }

      context "with a findable resource" do
        context "when the request has an id param" do
          let(:params) { { :id => "7" } }
          it "finds the on the model using that id" do
            model.should_receive(:find).with("7").and_return(instance)
            should == instance
          end
        end

        context "when a request that has no id param, but has model_id param" do
          let(:params) { { "model_id" => "7" } }
          it "finds the on the model using model_id" do
            model.should_receive(:find).with("7").and_return(instance)
            should == instance
          end
        end

      end

      context "with an unfindable resource" do
        let(:params) { { } }
        let(:builder) { stub }
        it "it builds a new instance of the resource" do
          model.should_receive(:new).and_return(instance)
          should == instance
        end
      end

      context "with a corresponding resource collection exposure defined" do
        let(:params) { { :id => 3 } }
        let(:scope) { double("Models") }
        before { controller.stub(:models => scope) }

        it "scopes find to that resource collection " do
          scope.should_receive(:find).with(3)
          subject
        end

        it "builds unfindable resources scoped to that resource collection " do
          controller.stub(:params => {}, :request => request, :models => scope)
          scope.should_receive(:new).and_return(instance)
          should == instance
        end
      end

      context "with a scope override specified" do
        let(:params) { { :id => 3 } }
        let(:models) { double("Models") }
        let(:collection) { double("Collection") }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, scope: :override_collection)
        end

        before do
          controller.stub(:models => models)
          controller.stub(:override_collection => collection)
        end

        it "uses the scope override to scope its queries" do
          models.should_not_receive(:find)
          collection.should_receive(:find).with(3)
          subject
        end
      end

    end

    context "with a resource collection" do
      let(:plural) { true }

      it "returns the scoped collection" do
        scoped = stub
        model.should_receive(:scoped).and_return(scoped)
        should == scoped
      end

      context "with a scope override specified" do

        let(:params) { { :id => 3 } }
        let(:models) { double("Models") }
        let(:association_scope) { double('AssociationScope') }
        let(:association) { double("Association", :scoped => association_scope) }
        let(:collection) { double("Collection", :models => association) }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, scope: :override_collection)
        end

        before do
          controller.stub(:models => models)
          controller.stub(:override_collection => collection)
        end

        it "uses the scope override to scope its queries" do
          should == association_scope
        end

      end
    end
  end
end
