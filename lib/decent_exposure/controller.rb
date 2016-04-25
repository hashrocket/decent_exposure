module DecentExposure
  module Controller
    extend ActiveSupport::Concern

    included do
      class_attribute :exposure_configuration,
        instance_accessor: false, instance_predicate: false
    end

    module ClassMethods
      # Public: Exposes an attribute to a controller Class.
      #
      # *args - An Array of attributes for the new exposure. See
      #         Exposure#initialize for attribute details.
      # block - If supplied, the exposed attribute method executes
      #         the Proc when accessed.
      #
      # Returns the helper methods that are now defined on the class
      # where this method is included.
      def expose(*args, &block)
        Exposure.expose! self, *args, &block
      end

      # Public: Exposes an attribute to a controller Class.
      # The exposed methods are then set to a before_action
      # callback.
      #
      # name  - The String name of the Exposure instance.
      # *args - An Array of attributes for the new exposure. See
      #         Exposure#initialize for attribute details.
      # block - If supplied, the exposed attribute method executes
      #         the Proc when accessed.
      #
      # Sets the exposed attribute to a before_action callback in the
      # controller.
      def expose!(name, *args, &block)
        expose name, *args, &block
        before_action name
      end

      # Public: Configures an Exposure instance for a controller Class.
      #
      # name    - The String name of the Exposure instance.
      # options - The Hash of options to configure the Exposure instance.
      #
      # Returns the exposure configuration Hash.
      def exposure_config(name, options)
        store = self.exposure_configuration ||= {}
        self.exposure_configuration = store.merge(name => options)
      end
    end
  end
end
