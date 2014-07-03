module AdequateExposure
  module Controller
    def expose(*args, &block)
      Exposure.expose! self, *args, &block
    end

    def expose!(name, *args, &block)
      expose name, *args, &block
      before_action name
    end
  end
end
