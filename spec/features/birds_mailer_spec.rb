require "spec_helper"
require "support/rails_app"
require "rspec/rails"
require "action_mailer"

class BirdsMailer < ActionMailer::Base
end

class BirdsMailer
  expose(:birds, -> { Bird.all })
  expose(:bird)

  def hello_birds
    mail { |format| format.text { render plain: "Hello #{birds}" } }
  end

  def hello_bird(id:)
    mail { |format| format.text { render plain: "Hello #{bird}" } }
  end

  def hello_bird_by_id(id)
    bird = Bird.find(id)
    mail { |format| format.text { render plain: "Hello #{bird}" } }
  end
end

RSpec.describe BirdsMailer, type: :mailer do
  let(:bird){ double :bird }
  let(:birds) { double :birds }

  context "when birds relation is exposed" do
    it "sends the email with exposed birds" do
      expect(Bird).to receive(:all).and_return(birds)
      expect(described_class.hello_birds.body.to_s)
        .to include("Hello #{birds}")
    end
  end

  context "when bird is exposed" do
    it "sends the email with exposed bird" do
      expect(Bird).to receive(:find).with('some-id').and_return(bird)
      expect(described_class.hello_bird(id: 'some-id').body.to_s)
        .to include("Hello #{bird}")
    end
  end

  context "with non hash argument" do
    it "does not set params" do
      expect(Bird).to receive(:find).with('some-id').and_return(bird)
      expect(described_class.hello_bird_by_id('some-id').body.to_s)
        .to include("Hello #{bird}")
    end
  end
end
