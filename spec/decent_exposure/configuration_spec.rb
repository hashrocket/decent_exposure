require 'decent_exposure/configuration'

describe DecentExposure::Configuration do
  context "with a configuration block" do
    subject do
      DecentExposure::Configuration.new do
        foo :bar
        baz :quuz
      end
    end

    describe '#options' do
      subject { super().options }
      it { is_expected.to eq({ :foo => :bar, :baz => :quuz }) }
    end
  end

  context "without a configuration block" do
    subject { DecentExposure::Configuration.new }

    describe '#options' do
      subject { super().options }
      it { is_expected.to eq({ }) }
    end
  end
end
