require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'active_model'

require 'rails'
require 'decent_exposure'

# Uncomment this if you are working on rails 5 fixes
# It will mute deprecation warnings (we need to refactor rails_integration_spec.rb to get rid of them)
# ActiveSupport::Deprecation.silenced = true

# Boilerplate
module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        get '/bird/new' => "bird#new"
        get '/birds' => "bird#index"
        get '/bird/(:id)' => "bird#show"
        get '/duck/(:id)' => "duck#show"
        get '/mallard/(:id)' => "mallard#show"
        get '/taxonomies/(:id)' => "taxonomies#show"
        get '/namespace/model/:id' => "namespace/model#show"
        get '/strong_parameters/:id' => "strong_parameters#show"
      end
      @routes
    end
  end

  def self.rails5?
    Rails.version.start_with?('5')
  end

  def self.application
    @app ||= App.new
  end
end
