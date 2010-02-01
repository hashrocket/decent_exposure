begin
  require File.join(File.dirname(__FILE__), 'lib', 'decent_exposure') # From here
rescue LoadError
  require 'decent_exposure' # From gem
end

ActionController::Base.extend(DecentExposure)
