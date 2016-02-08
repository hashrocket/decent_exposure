module DecentExposure
  class ResourceWrapper < ::SimpleDelegator
    def inspect
      "#<ActiveRecord::Relation>"
    end
  end
end
