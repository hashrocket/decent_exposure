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
          resources :birds

          namespace :api do
            resources :birds
          end
        end
      end
    end
  end

  def self.application
    @app ||= App.new
  end
end

class Bird
  attr_accessor :name
  def initialize(options = {})
    options.each do |k, v|
      self.public_send("#{k}=", v)
    end
  end
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

class BirdsController < ApplicationController
end

module Api
end

API_SUPER_CLASS = if Rails::VERSION::MAJOR < 5
                    ApplicationController
                  else
                    ActionController::API
                  end

class Api::BirdsController < API_SUPER_CLASS
end
