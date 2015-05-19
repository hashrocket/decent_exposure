require 'decent_exposure/strategizer'

RSpec.describe DecentExposure::Strategizer do
  describe "#strategy" do
    subject { exposure.strategy }

    context "when a block is given" do
      let(:block) { lambda { "foo" } }
      let(:exposure) { DecentExposure::Strategizer.new("foobar", &block) }
      it "saves the proc as the strategy" do
        expect(subject.block).to eq(block)
      end

      context "with a default object" do
        let(:exposure_strategy) { Proc.new { "default" } }
        let(:strategy) { exposure.strategy }
        let(:controller) { double("Controller") }

        before do
          allow(exposure).to receive(:exposure_strategy).and_return(exposure_strategy)
        end

        context "that doesn't get used" do
          let(:block) { lambda{|default| "foo" } }

          it "doesn't call the exposure_strategy" do
            expect(exposure_strategy).to_not receive(:call)
          end

          it "returns the block value" do
            expect(strategy.call(controller)).to eq("foo")
          end
        end

        context "that does get used" do
          let(:block) { lambda{|default| default.upcase } }

          it "calls the exposure strategy" do
            expect(exposure_strategy).to receive(:call).with(controller).and_call_original
          end

          it "returns the default value" do
            expect(strategy.call(controller)).to eq("DEFAULT")
          end
        end

        after do
          strategy.call(controller)
        end
      end
    end

    context "with no block" do
      context "with a custom strategy" do
        let(:exposure) { DecentExposure::Strategizer.new(name, :strategy => strategy) }
        let(:strategy) { double("Custom") }
        let(:instance) { double("custom") }
        let(:name) { "exposed" }

        it "initializes a provided class" do
          allow(DecentExposure::Exposure).to receive(:new).with(name, strategy,{:name => name}).and_return(instance)
          is_expected.to eq(instance)
        end
      end

      context "with no custom strategy" do
        let(:exposure) { DecentExposure::Strategizer.new(name, :model => model_option) }
        let(:strategy) { double("ActiveRecordStrategy") }
        let(:name) { "exposed" }
        let(:model_option) { :other }

        it "sets the strategy to Active Record" do
          allow(DecentExposure::Exposure).to receive(:new).
            with(name, DecentExposure::ActiveRecordWithEagerAttributesStrategy, {:model => :other, :name => name}).
            and_return(strategy)
          is_expected.to eq(strategy)
        end
      end
    end
  end
end
