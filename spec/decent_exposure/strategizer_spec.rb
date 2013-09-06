require 'decent_exposure/strategizer'

describe DecentExposure::Strategizer do
  describe "#strategy" do
    subject { exposure.strategy }

    context "when a block is given" do
      let(:block) { lambda {|default| "foo" } }
      let(:exposure) { DecentExposure::Strategizer.new("foobar", &block) }
      it "saves the proc as the strategy" do
        subject.block.should == block
      end

      context "with a default object" do
        let(:exposure_strategy) { Proc.new { "default" } }
        let(:strategy) { exposure.strategy }
        let(:controller) { double("Controller") }

        before do
          exposure.stub(:exposure_strategy) { exposure_strategy }
        end

        context "that doesn't get called" do
          let(:block) { lambda{|default| "foo" } }

          it "doesn't call the exposure_strategy" do
            exposure_strategy.should_not_receive(:call)
          end

          it "returns the block value" do
            strategy.call(controller).should == "foo"
          end
        end

        context "that does get called" do
          let(:block) { lambda{|default| default.call } }

          it "calls the exposure strategy" do
            exposure_strategy.should_receive(:call).with(controller)
          end

          it "returns the default value" do
            strategy.call(controller).should == "default"
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
