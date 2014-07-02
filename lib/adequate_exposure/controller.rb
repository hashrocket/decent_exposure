module AdequateExposure
  module Controller
    def expose(name, **options, &block)
      options = options.merge(name: name)
      options.reverse_merge! fetch: block if block_given?
      Exposure.new(options).expose! self
    end
  end
end
