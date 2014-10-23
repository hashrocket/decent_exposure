module AdequateExposure
  module Controller
    extend ActiveSupport::Concern

    included do
      class_attribute :exposure_configuration,
        instance_accessor: false, instance_predicate: false
    end

    module ClassMethods
      def expose(*args, &block)
        Exposure.expose! self, *args, &block
      end

      def expose!(name, *args, &block)
        expose name, *args, &block
        before_action name
      end

      def exposure_config(name, options)
        store = self.exposure_configuration ||= {}
        self.exposure_configuration = store.merge(name => options)
      end
    end
  end
end
