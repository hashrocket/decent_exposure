module AdequateExposure
  class Exposure
    attr_reader :controller, :options

    def self.expose!(*args, &block)
      new(*args, &block).expose!
    end

    def initialize(controller, name, *args, &block)
      @controller = controller
      options = args.extract_options!
      fetch_block = args.pop
      @options = options.with_indifferent_access.merge(name: name)

      merge_lambda_option :fetch, fetch_block if fetch_block
      merge_lambda_option :fetch, block if block_given?

      assert_singleton_option :fetch
      assert_singleton_option :from
      assert_incompatible_options_pair :parent, :model
      assert_incompatible_options_pair :parent, :scope
      assert_incompatible_options_pair :find_by, :find

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
      normalize_fetch_option
      normalize_with_option
      normalize_id_option
      normalize_model_option
      normalize_build_params_option
      normalize_scope_options
      normalize_parent_option
      normalize_from_option
      normalize_find_by_option
    end

    def normalize_fetch_option
      normalize_non_proc_option :fetch do |method_name|
        ->{ send(method_name) }
      end
    end

    def normalize_find_by_option
      if find_by = options.delete(:find_by)
        merge_lambda_option :find, ->(id, scope){ scope.find_by!(find_by => id) }
      end
    end

    def normalize_parent_option
      exposure_name = options.fetch(:name)

      if parent = options.delete(:parent)
        merge_lambda_option :scope, ->{ send(parent).send(exposure_name.to_s.pluralize) }
      end
    end

    def normalize_from_option
      exposure_name = options.fetch(:name)

      if from = options.delete(:from)
        merge_lambda_option :fetch, ->{ send(from).send(exposure_name) }
      end
    end

    def normalize_with_option
      if configs = options.delete(:with)
        Array.wrap(configs).each{ |config| reverse_merge_config! config }
      end
    end

    def normalize_id_option
      normalize_non_proc_option :id do |ids|
        ->{ Array.wrap(ids).map{ |id| params[id] }.find(&:present?) }
      end
    end

    def normalize_model_option
      normalize_non_proc_option :model do |value|
        model = if [String, Symbol].include?(value.class)
          value.to_s.classify.constantize
        else
          value
        end

        ->{ model }
      end
    end

    def normalize_build_params_option
      normalize_non_proc_option :build_params do |value|
        options[:build_params_method] = value
        nil
      end
    end

    def normalize_scope_options
      normalize_non_proc_option :scope do |custom_scope|
        ->(model){ model.send(custom_scope) }
      end
    end

    def normalize_non_proc_option(name)
      option_value = options[name]
      return if Proc === option_value
      if option_value.present?
        normalized_value = yield(option_value)
        if normalized_value
          merge_lambda_option name, normalized_value
        else
          options.delete name
        end
      end
    end

    def merge_lambda_option(name, body)
      if previous_value = options[name] and Proc === previous_value
        fail ArgumentError, "#{name.to_s.titleize} block is already defined"
      end

      options[name] = body
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

    def assert_incompatible_options_pair(key1, key2)
      if options.key?(key1) && options.key?(key2)
        fail ArgumentError, "Using #{key1.inspect} option with #{key2.inspect} doesn't make sense"
      end
    end

    def assert_singleton_option(name)
      if options.except(name, :name).any? && options.key?(name)
        fail ArgumentError, "Using #{name.inspect} option with other options doesn't make sense"
      end
    end

    def reverse_merge_config!(name)
      config = controller.exposure_configuration.fetch(name)
      options.reverse_merge! config
    end
  end
end
