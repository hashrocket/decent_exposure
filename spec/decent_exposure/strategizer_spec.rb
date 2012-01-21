require 'decent_exposure/strategizer'
require 'decent_exposure/active_record'

describe DecentExposure::Strategizer do
  describe "#strategy" do
    subject { exposure.strategy }
    context "when a block is given" do
      let(:block) { lambda { "foo" } }
      let(:exposure) { DecentExposure::Strategizer.new("foobar", nil, &block) }
      it "saves the proc as the strategy" do
        subject.block.should == block
      end
    end
    context "with no block" do
      let(:exposure) do
        DecentExposure::Strategizer.new(name, block)
      end
      let(:block) do
        lambda { |name| name.upcase }
      end
      let(:name) { "foo" }
      context "and a default exposure" do
        it "has a name" do
          subject.name.should == name
        end
        it "passes the name to the block" do
          context = stub
          subject.call(context).should == "FOO"
        end
      end

      context "and no default exposure" do
        let(:exposure) { DecentExposure::Strategizer.new(name, nil) }
        let(:strategy) { double("ActiveRecord") }
        let(:name) { "exposed" }

        it "sets the strategy to Active Record" do
          DecentExposure::ActiveRecord.should_receive(:new).with(name).and_return(strategy)
          should == strategy
        end
      end
    end
  end
end
