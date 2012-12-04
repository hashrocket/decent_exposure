require 'decent_exposure/inflector'


describe DecentExposure::Inflector do
  describe "#constant" do
    let(:name) { "fox" }
    let(:inflector) { DecentExposure::Inflector.new(name) }

    before do
      class Fox; end
      class Wolf; end
      module Dogs
        class Fox; end
        class Wolf; end
      end
    end

    it "looks up sibling constants" do
      inflector.constant(Dogs::Wolf).should == Dogs::Fox
    end

    it "looks up child constants" do
      inflector.constant(Dogs).should == Dogs::Fox
    end

    it "returns a constant from that word" do
      inflector.constant.should == Fox
    end

    it "returns a constant from that word" do
      inflector.constant(Wolf).should == Fox
    end

    it "raises when you pass in silly things" do
      expect do
        DecentExposure::Inflector.new("foo").constant
      end.to raise_error(NameError)
    end
  end

  describe "#parameter" do
    let(:name) { "fox" }
    let(:inflector) { DecentExposure::Inflector.new(name) }
    it "returns a string of the form 'word_id'" do
      inflector.parameter.should == "fox_id"
    end
  end

  describe "#plural?" do
    let(:inflector) { DecentExposure::Inflector.new(name) }
    subject { inflector.plural? }

    context "with a plural word" do
      let(:name) { "cars" }
      it { should be_true }
    end

    context "with a singular word" do
      let(:name) { "car" }
      it { should be_false }
    end

    context "with an uncountable word" do
      let(:name) { "sheep" }
      it { should be_false }
    end

    context "with a plural word and model option" do
      before { class Auto; end }
      let(:inflector) { DecentExposure::Inflector.new("cars", Auto) }
      it { should be_true }
    end
  end

  describe "#plural" do
    let(:inflector) { DecentExposure::Inflector.new(name) }
    let(:name) { "car" }
    it "pluralizes the passed-in string" do
      inflector.plural.should == "cars"
    end
  end

  describe "#singular" do
    let(:inflector) { DecentExposure::Inflector.new(name) }

    context "with a namespaced name" do
      let(:name) { "Content::Page" }
      it "returns a demodulized parameterized string" do
        inflector.singular.should == "page"
      end
    end

    context "with an already singular word" do
      let(:name) { "car" }
      it "returns the string" do
        inflector.singular.should == "car"
      end
    end

    context "with a plural word" do
      let(:name) { "cars" }
      it "returns the string in singular form" do
        inflector.singular.should == "car"
      end
    end

    context "with an uncountable word" do
      let(:name) { "sheep" }
      it "returns the string" do
        inflector.singular.should == "sheep"
      end
    end
  end
end
