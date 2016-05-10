require 'rails/generators'

module DecentExposure
  module Generators
    class ScaffoldTemplatesGenerator < Rails::Generators::Base
      desc 'Generate DecentExposure scaffold template files'
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine, desc: 'Template engine to be invoked (erb).'

      VIEWS = %i(_form edit index new show)
      AVAILABLE_ENGINES = %w(erb haml)

      def generate
        validate_template_engine

        generate_controller
        VIEWS.each { |view| generate_view(view) }
      end

      private

      def generate_controller
        copy_template('rails/scaffold_controller', 'controller.rb')
      end

      def generate_view(view)
        copy_template("#{engine}/scaffold", "#{view}.html.#{engine}")
      end

      def copy_template(generator, file)
        copy_file(file, "lib/templates/#{generator}/#{file}")
      end

      def engine
        options[:template_engine]
      end

      def validate_template_engine
        unless AVAILABLE_ENGINES.include?(engine.to_s)
          message = "ERROR: template_engine must be: #{AVAILABLE_ENGINES}."
          raise ArgumentError, message
        end
      end
    end
  end
end
