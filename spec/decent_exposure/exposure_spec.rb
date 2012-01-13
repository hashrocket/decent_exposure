require 'decent_exposure/exposure'
require 'decent_exposure/active_record'

describe DecentExposure::Exposure do
  describe "#strategy" do
    context "when a block is given" do
      let(:block) { lambda { "foo" } }
      let(:exposure) { DecentExposure::Exposure.new("foobar", &block) }
      it "saves the proc as the strategy" do
        exposure.strategy.should == block
      end
    end

    context "when no block is given" do
      let(:exposure) { DecentExposure::Exposure.new(name) }
      let(:strategy) { double("ActiveRecord") }
      let(:name) { "exposed" }

      it "sets the strategy to Active Record" do
        DecentExposure::ActiveRecord.should_receive(:new).with(name).and_return(strategy)
        exposure.strategy.should == strategy
      end
    end
  end

  describe "#call" do
    let(:block) { lambda { "foo" } }
    let(:exposure) { DecentExposure::Exposure.new("foobar", &block) }
    it "delegates to strategy" do
      exposure.call.should == "foo"
    end
  end
end
