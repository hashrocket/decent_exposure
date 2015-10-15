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
      expect(inflector.parameter).to eq("fox_id")
    end
  end

  describe "#plural?" do
    let(:inflector) { DecentExposure::Inflector.new(name, model) }
    subject { inflector.plural? }

    context "with a plural word" do
      let(:name) { "cars" }
      it { is_expected.to be_truthy }
    end

    context "with a singular word" do
      let(:name) { "car" }
      it { is_expected.to be_falsey }
    end

    context "with an uncountable word" do
      let(:name) { "sheep" }
      it { is_expected.to be_falsey }
    end

    context "with a plural word and model option" do
      before { class Auto; end }
      let(:inflector) { DecentExposure::Inflector.new("cars", Auto) }
      it { is_expected.to be_truthy }
    end
  end

  describe "#plural" do
    let(:inflector) { DecentExposure::Inflector.new(name, Car) }
    let(:name) { "car" }
    it "pluralizes the passed-in string" do
      expect(inflector.plural).to eq("cars")
    end
  end

  describe "#param_key" do
    let(:inflector) { DecentExposure::Inflector.new(name, model) }

    context "with a namespaced name" do
      before do
        module Content; class Page; end; end
      end

      let(:model) { Content::Page }
      let(:name) { "Content::Page" }
      it "returns a parameterized string" do
        expect(inflector.param_key).to eq("content_page")
      end
    end
  end

  describe "#singular" do
    let(:inflector) { DecentExposure::Inflector.new(name, model) }

    context "with an already singular word" do
      let(:name) { "car" }
      let(:model) { Car }
      it "returns the string" do
        expect(inflector.singular).to eq("car")
      end
    end

    context "with a plural word" do
      let(:name) { "cars" }
      let(:model) { Car }
      it "returns the string in singular form" do
        expect(inflector.singular).to eq("car")
      end
    end

    context "with an uncountable word" do
      before { class Sheep; end }
      let(:name) { "sheep" }
      let(:model) { Sheep }
      it "returns the string" do
        expect(inflector.singular).to eq("sheep")
      end
    end
  end
end
