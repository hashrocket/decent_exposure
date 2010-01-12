module Resourceful
  extend self
  def let(name, &block)
    define_method name do
      @__resources__       ||= {}
      @__resources__[name] ||= if block_given?
        instance_eval(&block)
      else
        class_for(name).find(params["#{name}_id"] || params['id'])
      end
    end
    helper_method name
    hide_action name
  end

  def class_for(name)
    name.to_s.classify.constantize
  end
end
