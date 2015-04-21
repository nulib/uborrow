#!/usr/bin/env ruby

require 'sinatra'
require 'rest_client'
require 'json'
require 'yaml'

module Uborrow
  class Application < Sinatra::Base
    
    configure do
      config_hash = YAML.load(File.read(File.expand_path('../config/uborrow.yml',__FILE__)))
      set :static, true
      set :public_folder, 'public'
      set :required_fields, config_hash['required_fields']
      set :availability_filter, config_hash['availability_filter']
    end
    
    helpers do
      def shim
        script_host = URI.parse(request.url).merge('/')
        %{<div id="uborrow-shim" data-uborrow-proxy="#{script_host.to_s}" data-uborrow-filter="#{settings.availability_filter}"><script src="#{script_host.merge('uborrow.js').to_s}"></script></div>}
      end
      
      def relais(path, payload)
        RestClient.post "https://rc.relais-host.com/#{path}", payload.merge(settings.required_fields).to_json, content_type: 'application/json'
      end
    end

    get '/uborrow.html' do
      shim
    end

    get '/findItem/:type/:value' do
      payload = {"ExactSearch" => [{"Type" => params[:type], "Value" => params[:value].to_s}]}
      response = JSON.parse(relais('/dws/item/available',payload))
      @link = response['Item']['RequestLink']['ButtonLink']
      @message = response['Item']['RequestLink']['RequestMessage']
      @selector = params[:target].to_s.empty? ? '.EXLResult' : "##{params[:target]}"
      erb :find_item, content_type: 'text/javascript'
    end
  end
end
