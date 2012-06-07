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
      context "and a default exposure" do
        let(:exposure) do
          DecentExposure::Strategizer.new(name, :default_exposure => block)
        end
        let(:block) do
          lambda { |name| name.upcase }
        end
        let(:name) { "foo" }
        it "has a name" do
          subject.name.should == name
        end
        it "passes the name to the block" do
          context = stub
          subject.call(context).should == "FOO"
        end
      end

      context "and no default exposure" do
        context "with a custom strategy" do
          let(:exposure) { DecentExposure::Strategizer.new(name, :default_exposure => nil, :strategy => strategy) }
          let(:strategy) { double("Custom") }
          let(:instance) { double("custom") }
          let(:name) { "exposed" }

          it "initializes a provided class" do
            DecentExposure::Exposure.should_receive(:new).with(name, strategy,{}).and_return(instance)
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
              with(model_option, DecentExposure::ActiveRecordWithEagerAttributesStrategy,{:model => :other}).
              and_return(strategy)
            should == strategy
          end
        end
      end
    end
  end

  describe "#model" do
    let(:exposure) { DecentExposure::Strategizer.new(name) }
    let(:name) { "exposed" }

    subject { exposure.model }

    context "with no model or collection option" do
      it "is the provided name" do
        should == name
      end
    end

    context "with a 'model' option"  do
      let(:exposure) { DecentExposure::Strategizer.new(name, :model => model_option) }
      let(:model_option) { :indecent }
      it "is the provided model" do
        should == model_option
      end
    end

    context "with a 'collection' option"  do
      let(:exposure) { DecentExposure::Strategizer.new(name, :collection => collection) }
      let(:collection) { :indecent }
      it "is the provided model" do
        should == collection
      end
    end
  end
end
