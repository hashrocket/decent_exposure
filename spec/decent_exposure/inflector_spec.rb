require 'decent_exposure/inflector'

class Fox; end

describe DecentExposure::Inflector do
  describe "#constant" do
    let(:name) { "fox" }
    let(:inflector) { DecentExposure::Inflector.new(name) }
    it "returns a constant from that word" do
      inflector.constant.should == Fox
    end
  end

  describe "#parameter" do
    let(:name) { "fox" }
    let(:inflector) { DecentExposure::Inflector.new(name) }
    it "returns a string of the form 'word_id'" do
      inflector.parameter.should == "fox_id"
    end
  end
end
