require 'decent_exposure/strategizer'
require 'decent_exposure/configuration'

module DecentExposure
  module Expose
    def self.extended(base)
      base.class_eval do
        class_attribute :_default_exposure
        def _resources
          @_resources ||= {}
        end
        hide_action :_resources
      end
    end

    def _exposures
      @_exposures ||= {}
    end

    def _decent_configurations
      @_decent_configurations ||= Hash.new(Configuration.new)
    end

    def decent_configuration(name=:default,&block)
      _decent_configurations[name] = Configuration.new(&block)
    end

    def default_exposure(&block)
      self._default_exposure = block
    end

    def expose!(*args, &block)
      set_callback(:process_action, :before, args.first)
      expose(*args, &block)
    end

    def expose(name, options={}, &block)
      options.merge!(:default_exposure => _default_exposure)
      _exposures[name] = exposure = Strategizer.new(name, options, &block).strategy

      define_method(name) do
        return _resources[name] if _resources.has_key?(name)
        _resources[name] = exposure.call(self)
      end

      helper_method name
      hide_action name
    end
  end
end
