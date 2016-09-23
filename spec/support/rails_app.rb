require "action_controller"
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

  def self.root
    ''
  end

  def self.application
    @app ||= App.new
  end
end

class Bird
  attr_accessor :name
  def initialize(options = {})
    options.each { |k, v| self.public_send("#{k}=", v) }
  end
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

def base_api_class
  return ApplicationController if Rails::VERSION::MAJOR < 5
  ActionController::API
end

class BirdsController < ApplicationController
  %i(index show edit new create update).each do |action|
    define_method action do
      head :ok
    end
  end
end

module Api
  class BirdsController < base_api_class
    %i(index show edit new create update).each do |action|
      define_method action do
        head :ok
      end
    end
  end
end
