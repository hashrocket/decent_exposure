require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'active_model'
require 'active_record'

require 'decent_exposure'

# Boilerplate
module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        get '/bird/new' => "bird#new"
        get '/bird/(:id)' => "bird#show"
        get '/duck/(:id)' => "duck#show"
        get '/mallard/(:id)' => "mallard#show"
      end
      @routes
    end
  end
  def self.application
    App.new
  end
end
