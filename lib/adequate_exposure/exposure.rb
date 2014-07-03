module AdequateExposure
  class Exposure
    attr_reader :controller, :options

    def self.expose!(*args, &block)
      new(*args, &block).expose!
    end

    def initialize(controller, name, **options, &block)
      @controller = controller
      @options = options.merge(name: name).with_indifferent_access

      if block_given?
        @options.merge! fetch: block
      end

      normalize_options
    end

    def expose!
      expose_attribute!
      expose_helper_methods!
    end

    private

    def expose_attribute!
      attribute.expose! controller
    end

    def expose_helper_methods!
      helper_methods = [ attribute.getter_method_name, attribute.setter_method_name ]
      controller.helper_method *helper_methods
    end

    def normalize_options
      normalize_non_proc_option :id do |ids|
        ->{ Array.wrap(ids).map{ |id| params[id] }.find(&:present?) }
      end

      normalize_non_proc_option :model do |value|
        model = if [String, Symbol].include?(value.class)
          value.to_s.classify.constantize
        else
          value
        end

        ->{ model }
      end
    end

    def normalize_non_proc_option(name)
      option_value = options[name]
      return if Proc === option_value
      options[name] = yield(option_value) if option_value.present?
    end

    def attribute
      @attribute ||= begin
        local_options = options

        name = options.fetch(:name)
        ivar_name = "exposed_#{name}"
        fetch = ->{ Flow.new(self, local_options).fetch }

        Attribute.new(
          name: name,
          ivar_name: ivar_name,
          fetch: fetch
        )
      end
    end
  end
end
