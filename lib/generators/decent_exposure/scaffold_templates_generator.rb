require "rails/generators"

module DecentExposure
  module Generators
    class ScaffoldTemplatesGenerator < Rails::Generators::Base
      desc 'Generate DecentExposure scaffold template files'
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine, desc: 'Template engine to be invoked (erb, haml or slim).'

      def generate
        copy_file 'controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb'
      end
    end
  end
end
