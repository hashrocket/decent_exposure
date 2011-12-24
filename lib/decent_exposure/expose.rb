require 'decent_exposure/exposure'

module DecentExposure
  module Expose
    def _exposures
      @_exposures ||= {}
    end

    def self.extended(base)
      base.class_eval do
        def _resources
          @_resources ||= {}
        end
        hide_action :_resources
      end
    end

    def expose(name, &block)
      _exposures[name] = exposure = DecentExposure::Exposure.new(name, &block)

      define_method(name) do
        return _resources[name] if _resources.has_key?(name)
        _resources[name] = exposure.call(request)
      end

      helper_method name
      hide_action name
    end
  end
end
