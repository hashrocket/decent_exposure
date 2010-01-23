begin
  require File.join(File.dirname(__FILE__), 'lib', 'let_it_be') # From here
rescue LoadError
  require 'let_it_be' # From gem
end

ActionController::Base.extend(LetItBe)
