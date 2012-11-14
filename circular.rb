require 'rubygems'
require 'bundler'

Bundler.require

require File.join(File.dirname(__FILE__),'helpers.rb')

class Circular < Sinatra::Base
  @@sprockets = {}
  def self.sprockets
    @@sprockets
  end

  helpers Sinatra::Sprockets::Helpers

  # Load all applications in ./apps
  dirs = Dir.glob(File.join(File.dirname(__FILE__),'apps/*'))
  apps = dirs.map { |d| File.basename(d).to_sym }

  apps.each do |app|
    @@sprockets[app] = Sprockets::Environment.new
    set app, @@sprockets[app] 
    app_set = settings.send(app) 
    app_set.append_path "apps/#{app}/javascripts"
    app_set.append_path "apps/#{app}/stylesheets"
    app_set.append_path "apps/#{app}/templates"
    app_set.append_path "apps/#{app}/images"


    get "/#{app}/:file.js" do
      content_type "application/javascript"
      app_set["#{params[:file]}.js"]
    end

    get "/#{app}/:file.css" do
      content_type "text/css"
      app_set["#{params[:file]}.css"]
    end

    get "/#{app}/*.*" do 
      path = params[:splat].join(".")
      app_set[path]
    end

  end

  get "/applications.json" do
    { 
      :applications => Circular.sprockets.keys
    }.to_json
  end


  get "/:application" do
    puts params[:application]
    erb :application, :locals => {:application => params[:application].to_sym}
  end
  
  
  
  get "/" do 
    redirect to("/circular")
  end 
end

