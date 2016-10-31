module DecentExposure
  module Mailer
    def self.included(base)
      base.class_eval do
        attr_accessor :params

        def process_action(*args)
          arg = args.second
          self.params = arg.stringify_keys() if arg && Hash === arg
          super
        end
      end
    end
  end
end
