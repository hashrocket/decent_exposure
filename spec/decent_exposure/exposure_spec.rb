require 'decent_exposure/exposure'

describe DecentExposure::Exposure do
  describe "#strategy" do
    context "when a block is given" do
      let(:block) { lambda { "foo" } }
      let(:exposure) { DecentExposure::Exposure.new("foobar", &block) }
      it "saves the proc as the strategy" do
        exposure.strategy.should == block
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
