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

  context 'with haml' do
    before do
      allow(generator).to receive(:options).and_return(template_engine: :haml)
    end

    it 'generates controller and haml views' do
      allow(generator).to receive(:copy_file).with('controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb')
      allow(generator).to receive(:copy_file).with('_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml')
      allow(generator).to receive(:copy_file).with('edit.html.haml', 'lib/templates/haml/scaffold/edit.html.haml')
      allow(generator).to receive(:copy_file).with('index.html.haml', 'lib/templates/haml/scaffold/index.html.haml')
      allow(generator).to receive(:copy_file).with('new.html.haml', 'lib/templates/haml/scaffold/new.html.haml')
      allow(generator).to receive(:copy_file).with('show.html.haml', 'lib/templates/haml/scaffold/show.html.haml')

      generator.generate
    end
  end

  context 'with invalid template_engine' do
    before do
      allow(generator).to receive(:options).and_return(template_engine: :foo_bar)
    end

    it 'raises an ArgumentError' do
      expect { generator.generate }. to raise_error(ArgumentError)
    end
  end
end
