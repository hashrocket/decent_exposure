require 'decent_exposure/inflector'

class Car; end
class Fox; end

describe DecentExposure::Inflector do
  let(:model) { Object }

  describe "#parameter" do
    let(:name) { "fox" }
    let(:model) { Fox }
    let(:inflector) { DecentExposure::Inflector.new(name, model) }
    it "returns a string of the form 'word_id'" do
      inflector.parameter.should == "fox_id"
    end
  end

  describe "#plural?" do
    let(:inflector) { DecentExposure::Inflector.new(name, model) }
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
    let(:inflector) { DecentExposure::Inflector.new(name, Car) }
    let(:name) { "car" }
    it "pluralizes the passed-in string" do
      inflector.plural.should == "cars"
    end
  end

  describe "#singular" do
    let(:inflector) { DecentExposure::Inflector.new(name, model) }

    context "with a namespaced name" do
      before do
        module Content; class Page; end; end
      end

      let(:model) { Content::Page }
      let(:name) { "Content::Page" }
      it "returns a parameterized string" do
        inflector.singular.should == "page"
      end
    end

    context "with an already singular word" do
      let(:name) { "car" }
      let(:model) { Car }
      it "returns the string" do
        inflector.singular.should == "car"
      end
    end

    context "with a plural word" do
      let(:name) { "cars" }
      let(:model) { Car }
      it "returns the string in singular form" do
        inflector.singular.should == "car"
      end
    end

    context "with an uncountable word" do
      before { class Sheep; end }
      let(:name) { "sheep" }
      let(:model) { Sheep }
      it "returns the string" do
        inflector.singular.should == "sheep"
      end
    end
  end
end
