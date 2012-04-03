module DecentExposure
  module DefaultExposureFinder
    def inherited(klass)
      closured_exposure_finder = default_exposure_finder
      klass.class_eval do
        default_exposure_finder(closured_exposure_finder)
      end
      super
    end

    attr_accessor :_default_exposure_finder

    def default_exposure_finder(finder = nil)
      return :find if finder.nil? && self._default_exposure_finder.nil?
      self._default_exposure_finder = finder if finder
      self._default_exposure_finder
    end
  end
end
