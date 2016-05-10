require 'spec_helper'

RSpec.describe DecentExposure::Generators::ScaffoldTemplatesGenerator, type: :generator do

  subject(:generator) { described_class.new }

  context 'with erb' do
    it 'generates controller and erb views' do
      allow(generator).to receive(:copy_file).with('controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb')
      allow(generator).to receive(:copy_file).with('_form.html.erb', 'lib/templates/erb/scaffold/_form.html.erb')
      allow(generator).to receive(:copy_file).with('edit.html.erb', 'lib/templates/erb/scaffold/edit.html.erb')
      allow(generator).to receive(:copy_file).with('index.html.erb', 'lib/templates/erb/scaffold/index.html.erb')
      allow(generator).to receive(:copy_file).with('new.html.erb', 'lib/templates/erb/scaffold/new.html.erb')
      allow(generator).to receive(:copy_file).with('show.html.erb', 'lib/templates/erb/scaffold/show.html.erb')

      generator.generate
    end
  end
end
