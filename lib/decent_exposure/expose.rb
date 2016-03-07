require 'decent_exposure/strategizer'
require 'decent_exposure/configuration'

module DecentExposure
  module Expose
    def self.extended(base)
      base.class_eval do
        class_attribute :_decent_configurations
        self._decent_configurations ||= Hash.new(Configuration.new)

        def _resources
          @_resources ||= {}
        end

        #backwards compatibility for rails 4.0.x
        if self.const_defined? "PROTECTED_IVARS"
          self::PROTECTED_IVARS << :@_resources
        else
          protected_instance_variables << "@_resources"
        end
      end
    end

    def _exposures
      @_exposures ||= {}
    end

    def decent_configuration(name=:default,&block)
      self._decent_configurations = _decent_configurations.merge(name => Configuration.new(&block))
    end

    def expose!(*args, &block)
      set_callback(:process_action, :before, args.first)
      expose(*args, &block)
    end

    def expose(name, options={}, &block)
      if ActionController::Base.instance_methods.include?(name.to_sym)
        Kernel.warn "[WARNING] You are exposing the `#{name}` method, " \
          "which overrides an existing ActionController method of the same name. " \
          "Consider a different exposure name\n" \
          "#{caller.first}"
      end

      config = options[:config] || :default
      options = _decent_configurations[config].merge(options)

      _exposures[name] = exposure = Strategizer.new(name, options, &block).strategy

      define_exposure_methods(name, exposure)
    end

    private

    def define_exposure_methods(name, exposure)
      define_method(name) do
        return _resources[name] if _resources.has_key?(name)
        _resources[name] = exposure.call(self)
      end
      helper_method name

      define_method("#{name}=") do |value|
        _resources[name] = value
      end
    end
  end
end
