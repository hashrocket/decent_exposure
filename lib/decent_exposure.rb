
module DecentExposure
  autoload :Base, 'decent_exposure/base'
  autoload :InstanceEval, 'decent_exposure/instance_eval'
  autoload :ActiveModel, 'decent_exposure/active_model'

  require 'decent_exposure/railtie'

  def inherited(klass)
    closured_exposure = default_exposure
    klass.class_eval do
      default_exposure(&closured_exposure)
    end
    super
  end

  attr_accessor :_default_exposure

  def default_exposure(&block)
    if block_given?
      # Deprecate at some point
      self._default_exposure = Class.new(InstanceEval) do
        define_method :call do
          if @block
            super
          else
            controller.instance_exec(name, &block)
          end
        end
      end
    end
    _default_exposure
  end

  def default_exposure=(klass)
    self._default_exposure = klass
  end

  def expose(name, &block)
    klass = default_exposure || InstanceEval
    define_method name do
      @_resources       ||= {}
      @_resources[name] ||= klass.new(self, name, &block).call
    end
    helper_method name
    hide_action name
  end

end
