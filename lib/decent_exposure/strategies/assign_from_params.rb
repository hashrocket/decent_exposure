module DecentExposure
  module Strategies
    module AssignFromParams
      def attributes
        params[options[:param_key] || inflector.param_key] || {}
      end

      def assign_attributes?
        return false unless attributes && singular?
        (!get? && !delete?) || new_record?
      end

      def new_record?
        !id
      end

      def resource
        super.tap do |r|
          r.attributes = attributes if assign_attributes?
        end
      end
    end
  end
end
