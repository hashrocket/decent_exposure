require 'decent_exposure/configuration'

describe DecentExposure::Configuration do
  context "with a configuration block" do
    subject do
      DecentExposure::Configuration.new do
        foo :bar
        baz :quuz
      end
    end

    its(:options) { should == { :foo => :bar, :baz => :quuz } }
  end

  context "without a configuration block" do
    subject { DecentExposure::Configuration.new }
    its(:options) { should == { } }
  end
end
