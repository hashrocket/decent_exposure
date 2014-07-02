require "active_support/all"
require "action_controller"
require "action_dispatch"
require "rails"

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

class Bird
end

class ApplicationConroller < ActionController::Base
  include Rails.application.routes.url_helpers
end

class BirdsController < ApplicationConroller
  expose :bird

  def show
    render nothing: true
  end
end

