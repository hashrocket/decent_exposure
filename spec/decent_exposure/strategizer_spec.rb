require 'decent_exposure/strategizer'

describe DecentExposure::Strategizer do
  describe "#strategy" do
    subject { exposure.strategy }

    context "when a block is given" do
      let(:block) { lambda { "foo" } }
      let(:exposure) { DecentExposure::Strategizer.new("foobar", &block) }
      it "saves the proc as the strategy" do
        subject.block.should == block
      end
    end

    context "with no block" do
      context "with a custom strategy" do
        let(:exposure) { DecentExposure::Strategizer.new(name, :strategy => strategy) }
        let(:strategy) { double("Custom") }
        let(:instance) { double("custom") }
        let(:name) { "exposed" }

        it "initializes a provided class" do
          DecentExposure::Exposure.should_receive(:new).with(name, strategy,{:name => name}).and_return(instance)
          should == instance
        end
      end

      context "with no custom strategy" do
        let(:exposure) { DecentExposure::Strategizer.new(name, :model => model_option) }
        let(:strategy) { double("ActiveRecordStrategy") }
        let(:name) { "exposed" }
        let(:model_option) { :other }

        it "sets the strategy to Active Record" do
          DecentExposure::Exposure.should_receive(:new).
            with(name, DecentExposure::ActiveRecordWithEagerAttributesStrategy, {:model => :other, :name => name}).
            and_return(strategy)
          should == strategy
        end
      end
    end
  end
end
