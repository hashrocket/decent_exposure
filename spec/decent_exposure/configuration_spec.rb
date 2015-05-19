require 'decent_exposure/configuration'

RSpec.describe DecentExposure::Configuration do
  context "with a configuration block" do
    let(:config) do
      DecentExposure::Configuration.new do
        foo :bar
        baz :quuz
      end
    end

    describe "#options" do
      it "returns hash of set attributes" do
        expect(config.options).to eq({ :foo => :bar, :baz => :quuz })
      end
    end
  end

  context "without a configuration block" do
    let(:config) { DecentExposure::Configuration.new }

    describe "#options" do
      it "returns empty hash" do
        expect(config.options).to eq({})
      end
    end
  end
end
