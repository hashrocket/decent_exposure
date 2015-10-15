require 'decent_exposure/active_record_strategy'

describe DecentExposure::ActiveRecordStrategy do
  describe "#resource" do
    let(:inflector) do
      double("Inflector", :parameter => "model_id", :plural? => plural, :plural => 'models', :singular => 'model')
    end
    let(:model) { double("Model", :new => nil) }
    let(:params) { Hash.new }
    let(:request) { double('request', :post? => false, :put? => false, :patch? => false) }
    let(:config) { double('config', :options => {}) }
    let(:controller_class) { double('controller_class', :_decent_configurations => Hash.new(config)) }
    let(:controller) { double('controller', :params => params, :request => request, :class => controller_class) }
    let(:strategy) { DecentExposure::ActiveRecordStrategy.new(controller, inflector) }

    before do
      strategy.model = model
      strategy.inflector = inflector
    end

    subject { strategy.resource }

    context "with a singular resource" do
      let(:instance) { double }
      let(:plural) { false }

      context "with a findable resource" do
        context "when the request has an id param" do
          let(:params) { { :id => "7" } }
          it "finds the on the model using that id" do
            expect(model).to receive(:find).with("7").and_return(instance)
            is_expected.to eq(instance)
          end
        end

        context "when a request that has no id param, but has model_id param" do
          let(:params) { { "model_id" => "7" } }
          it "finds the on the model using model_id" do
            expect(model).to receive(:find).with("7").and_return(instance)
            is_expected.to eq(instance)
          end
        end

      end

      context "with an unfindable resource" do
        let(:params) { { } }
        let(:builder) { double }
        it "it builds a new instance of the resource" do
          expect(model).to receive(:new).and_return(instance)
          is_expected.to eq(instance)
        end
      end

      context "with a corresponding resource collection exposure defined" do
        let(:params) { { :id => 3 } }
        let(:scope) { double("Models") }
        before { allow(controller).to receive_messages(:models => scope) }

        it "scopes find to that resource collection " do
          expect(scope).to receive(:find).with(3)
          subject
        end

        it "builds unfindable resources scoped to that resource collection " do
          allow(controller).to receive_messages(:params => {}, :request => request, :models => scope)
          expect(scope).to receive(:new).and_return(instance)
          is_expected.to eq(instance)
        end
      end

      context "with a scope override specified" do
        let(:params) { { :id => 3 } }
        let(:models) { double("Models") }
        let(:collection) { double("Collection") }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, :ancestor => :override_collection)
        end

        before do
          allow(controller).to receive_messages(:models => models)
          allow(controller).to receive_messages(:override_collection => collection)
        end

        it "uses the scope override to scope its queries" do
          expect(models).not_to receive(:find)
          expect(collection).to receive(:find).with(3)
          subject
        end
      end

      context "with a finder override specified" do
        let(:params) { { :id => 'article-title-slug' } }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, :finder => :find_by_slug)
        end

        it "uses the finder override to find instances" do
          expect(model).to receive(:find_by_slug).with('article-title-slug')
          subject
        end
      end

      context "with a params method override specified" do
        let(:filtered_params) { { :id => 3 } }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, :params => :filtered_params)
        end
        before do
          allow(model).to receive(:find)
          allow(controller).to receive_messages(:filtered_params => filtered_params)
        end

        it "uses the params method override" do
          expect(controller).not_to receive(:params)
          expect(controller).to receive(:filtered_params)
          subject
        end
      end

      context "with a parameter key override specified" do
        let(:params) { { "slug" => 'article-title-slug' } }
        let(:slug) { double('Slug') }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, :finder_parameter => "slug")
        end

        it "uses the params method override" do
          expect(model).to receive(:find).with('article-title-slug')
          subject
        end

        context "when the implicit finder parameter is also present" do
          let(:params) { { "model_id" => "model_id", "slug" => 'article-title-slug' } }
          it "prefers passed-in finder parameter to implicit one" do
            expect(model).to receive(:find).with('article-title-slug')
            subject
          end
        end
      end
    end

    context "with a resource collection" do
      let(:plural) { true }
      let(:scoped) { double('Scoped') }

      context "with ActiveRecord 3" do
        before do
          stub_const("ActiveRecord::VERSION::MAJOR", 3)
        end
        it "returns the scoped collection" do
          expect(model).to receive(:scoped).and_return(scoped)
          is_expected.to eq(scoped)
        end
      end

      context "with ActiveRecord 4" do
        before do
          stub_const("ActiveRecord::VERSION::MAJOR", 4)
        end
        it "returns the scoped collection" do
          expect(model).to receive(:all).and_return(scoped)
          is_expected.to eq(scoped)
        end
      end

      context "with a scope override specified" do

        let(:params) { { :id => 3 } }
        let(:models) { double("Models") }
        let(:association_scope) { double('AssociationScope') }
        let(:association) { double("Association", :scoped => association_scope, :all => association_scope) }
        let(:collection) { double("Collection", :models => association) }
        let(:strategy) do
          DecentExposure::ActiveRecordStrategy.new(controller, inflector, :ancestor => :ancestor_collection)
        end

        before do
          allow(controller).to receive_messages(:models => models)
          allow(controller).to receive_messages(:ancestor_collection => collection)
        end

        it "uses the scope override to scope its queries" do
          is_expected.to eq(association_scope)
        end

      end
    end
  end
end
