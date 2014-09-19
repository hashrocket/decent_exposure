module AdequateExposure
  module Behavior
    def fetch
      instance = id ? find(id, computed_scope) : build(build_params, computed_scope)
      decorate(instance)
    end

    def id
      params_id_key_candidates.each do |key|
        value = params[key]
        return value if value.present?
      end

      nil
    end

    def scope(model)
      model
    end

    def model
      name.to_s.classify.constantize
    end

    def find(id, scope)
      scope.find(id)
    end

    def build(params, scope)
      scope.new(params)
    end

    def decorate(instance)
      instance
    end

    def build_params
      if controller.respond_to?(params_method_name, true) && !get_request?
        controller.send(params_method_name)
      else
        {}
      end
    end

    protected

    def params_id_key_candidates
      [ "#{model.name.underscore}_id", "#{name}_id", "id" ].uniq
    end

    def model_param_key
      model.name.underscore
    end

    def computed_scope
      scope(model)
    end
  end
end
