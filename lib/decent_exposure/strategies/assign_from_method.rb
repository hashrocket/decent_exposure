module DecentExposure
  module Strategies
    module AssignFromMethod
      def attributes
        return @attributes if defined?(@attributes)
        @attributes = controller.send(options[:attributes]) if options[:attributes]
      end

      def assign_attributes?
        singular? && (post? || put? || patch?) && attributes.present?
      end

      def resource
        assign_attributes? ? super(attributes) : super
      end
    end
  end
end
