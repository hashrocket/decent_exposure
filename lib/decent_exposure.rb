module DecentExposure
  def expose(name, &block)
    define_method name do
      @_resources       ||= {}
      @_resources[name] ||= if block_given?
        instance_eval(&block)
      else
        _class_for(name).find(params["#{name}_id"] || params['id'])
      end
    end
    helper_method name
    hide_action name
  end

  alias let expose

  private
  def _class_for(name)
    name.to_s.classify.constantize
  end
end
