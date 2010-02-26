begin
  require File.join(File.dirname(__FILE__), 'lib', 'decent_exposure') # From here
rescue LoadError
  require 'decent_exposure' # From gem
end

ActionController::Base.class_eval do
  extend DecentExposure
  superclass_delegating_accessor :_default_exposure
  default_exposure do |name|
    model_class = name.to_s.classify.constantize
    model_class.find(params["#{name}_id"] || params['id'])
  end
end
