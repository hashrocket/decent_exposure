require 'decent_exposure/railtie'

module DecentExposure
  def inherited(klass)
    closured_exposure = default_exposure
    klass.class_eval do
      default_exposure(&closured_exposure)
    end
    super
  end

  attr_accessor :_default_exposure

  def default_exposure(&block)
    self._default_exposure = block if block_given?
    _default_exposure
  end

  def expose(name, &block)
    closured_exposure = default_exposure
    define_method name do
      resource = instance_variable_get("@#{name}")
      if !resource
        resource = if block_given?
          instance_eval(&block)
        else
          instance_exec(name, &closured_exposure)
        end

        instance_variable_set "@#{name}", resource
      end

      return resource
    end
    helper_method name
    hide_action name
  end
end
