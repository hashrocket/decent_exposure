module DecentExposure
  class InstanceEval < Base
    def call
      controller.instance_eval(&block)
    end
  end
end
