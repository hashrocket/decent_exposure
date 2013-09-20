module DecentExposure
  module Strategies
    module AssignFromMethod
      def attributes
        return @attributes if defined?(@attributes)
        @attributes = controller.send(options[:attributes]) if options[:attributes]
      end

      def assign_attributes?
        singular? && !get? && !delete? && attributes.present?
      end

      def resource
        super.tap do |r|
          r.attributes = attributes if assign_attributes?
        end
      end
    end
  end
end
