module DecentExposure
  module Strategies
    module AssignFromParams
      def attributes
        params[options[:param_key] || inflector.param_key] || {}
      end

      def assign_attributes?
        return false unless attributes && singular?
        post? || put? || patch? || new_record?
      end

      def new_record?
        !id
      end

      def resource
        assign_attributes? ? super(attributes) : super
      end
    end
  end
end
