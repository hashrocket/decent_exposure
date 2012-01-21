require 'decent_exposure/strategizer'

module DecentExposure
  module Expose
    def self.extended(base)
      base.class_eval do
        cattr_accessor :_default_exposure
        def _resources
          @_resources ||= {}
        end
        hide_action :_resources
      end
    end

    def _exposures
      @_exposures ||= {}
    end

    def default_exposure(&block)
      self._default_exposure = block
    end

    def expose(name, &block)
      _exposures[name] = exposure = DecentExposure::Strategizer.new(name, _default_exposure, &block).strategy

      define_method(name) do
        return _resources[name] if _resources.has_key?(name)
        _resources[name] = exposure.call(self)
      end

      helper_method name
      hide_action name
    end
  end
end
