module DecentExposure
  module Mailer
    def self.included(base)
      base.class_eval do
        attr_accessor :params

        def process_action(*args)
          self.params = args.second.stringify_keys() if args.second
          super
        end
      end
    end
  end
end
