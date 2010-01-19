module LetItBe
  def let(name, &block)
    define_method name do
      @__resources__       ||= {}
      @__resources__[name] ||= if block_given?
        instance_eval(&block)
      else
        __class_for__(name).find(params["#{name}_id"] || params['id'])
      end
    end
    helper_method name
    hide_action name
  end

  private
  def __class_for__(name)
    name.to_s.classify.constantize
  end
end
