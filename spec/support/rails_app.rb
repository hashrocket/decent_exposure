require "active_support/all"
require "action_controller"
require "action_dispatch"
require "rails"

def request_params(params)
  return params if Rails::VERSION::MAJOR < 5
  { params: params }
end

module Rails
  class App
    def env_config; {} end

    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new.tap do |routes|
        routes.draw do
          resource :birds
        end
      end
    end
  end

  def self.application
    @app ||= App.new
  end
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end
