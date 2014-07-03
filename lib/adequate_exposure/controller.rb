module AdequateExposure
  module Controller
    def expose(*args, &block)
      Exposure.expose! self, *args, &block
    end
  end
end
