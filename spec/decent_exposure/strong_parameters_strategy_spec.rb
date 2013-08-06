require 'decent_exposure/strong_parameters_strategy'
require 'active_support/core_ext'

describe DecentExposure::StrongParametersStrategy do
  describe "#assign_attributes?" do
    let(:inflector) do
      double("Inflector", :plural? => plural)
    end
    let(:plural) { false }
    let(:request) { double('request', :get? => true) }
    let(:controller) { double('controller', :params => {}, :request => request) }
    let(:options) { {} }
    let(:strategy) { described_class.new(controller, inflector, options) }

    subject { strategy.assign_attributes? }

    before do
      strategy.inflector = inflector
    end

    context "when the resource is a collection (plural)" do
      let(:plural) { true }
      it { should be_false }
    end

    context "for a get request" do
      let(:request) { double('request', :get? => true, :delete? => false) }
      it { should be_false }
    end

    context "for a delete request" do
      let(:request) { double('request', :delete? => true, :get? => false) }
      it { should be_false }
    end

    context "for a post/put/patch request" do
      let(:request) { double('request', :get? => false, :delete? => false) }

      context "and the :attributes option is set" do
        let(:options) { { :attributes => :my_attributes } }
        before do
          controller.stub(:my_attributes).and_return(results)
        end

        context "and sending the attributes method returns a non-blank value" do
          let(:results) { { :hello => "there" } }
          it { should be_true }
        end

        context "and sending the attributes method returns a blank value" do
          let(:results) { {} }
          it { should be_false }
        end
      end

      context "and the :attributes option is not set" do
        it { should be_false }
      end
    end
  end
end
