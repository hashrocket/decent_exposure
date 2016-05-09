require 'spec_helper'

RSpec.describe DecentExposure::Generators::ScaffoldTemplatesGenerator, type: :generator do

  subject(:generator) { described_class.new }

  it 'generates controller' do
    allow(generator).to receive(:copy_file).with('controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb')

    generator.generate
  end
end
