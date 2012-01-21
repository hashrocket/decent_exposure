require 'decent_exposure/inflector'

module DecentExposure
  class ActiveRecord
    attr_reader :name, :inflector

    def initialize(name)
      @name = name
      @inflector = DecentExposure::Inflector.new(name)
    end

    def call(controller)
      Finder.new(controller, inflector).resource
    end

    class Finder
      attr_reader :controller, :inflector

      def initialize(controller, inflector)
        @controller, @inflector = controller, inflector
      end

      def model
        inflector.constant
      end

      def collection
        inflector.plural
      end

      def plural?
        inflector.plural?
      end

      def parameter
        inflector.parameter
      end

      def scope
        if controller.respond_to?(collection.to_sym) && !plural?
          controller.send(collection.to_sym)
        else
          model
        end
      end

      def singular_param
        inflector.singular
      end

      def get?
        controller.request.get?
      end

      def params
        controller.params
      end

      def collection_resource
        scope.scoped
      end

      def attributes
        params[singular_param] || {}
      end

      def singular_resource
        if id = params[parameter] || params[:id]
          scope.find(id).tap do |instance|
            instance.attributes = attributes unless get?
          end
        else
          scope.new(attributes)
        end
      end

      def resource
        if plural?
          collection_resource
        else
          singular_resource
        end
      end
    end

  end
end
