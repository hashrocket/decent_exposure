require 'decent_exposure/constant_resolver'

describe DecentExposure::ConstantResolver do
  describe "#constant" do
    before do
      class Fox; end
      class Wolf; end
      module Dogs
        class Fox; end
        class Wolf; end
      end
    end

    context "with a non-classified string" do
      let(:name) { "fox" }
      it "looks up sibling constants" do
        resolver = described_class.new(name, Dogs::Wolf)
        resolver.constant.should == Dogs::Fox
      end

      it "looks up child constants" do
        resolver = described_class.new(name, Dogs)
        resolver.constant.should == Dogs::Fox
      end

      it "returns a constant from that word without a context" do
        resolver = described_class.new(name)
        resolver.constant.should == Fox
      end

      it "returns a siblings without a context (top-level constants)" do
        resolver = described_class.new(name, Wolf)
        resolver.constant.should == Fox
      end
    end

    context "with a classified string" do
      let(:name) { "Fox" }
      it "looks up sibling constants" do
        resolver = described_class.new(name, Dogs::Wolf)
        resolver.constant.should == Dogs::Fox
      end
    end

    it "raises when you pass in silly things" do
      expect do
        described_class.new(Dogs, "foo").constant
      end.to raise_error(NameError)
    end

  end
end
