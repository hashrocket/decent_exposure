module DecentExposure
  module Mailer
    def self.included(base)
      base.class_eval do
        attr_accessor :params

        def process_action(*args)
          arg = args.second
          self.params = arg.stringify_keys if arg && Hash === arg
          super
        end
        ruby2_keywords(:process_action) if respond_to?(:ruby2_keywords, true)
      end
    end
  end
end
