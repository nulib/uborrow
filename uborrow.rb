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
        %{<script id="uborrow-shim" data-uborrow-proxy="#{script_host.to_s}" data-uborrow-filter="#{settings.availability_filter}" src="#{script_host.merge('uborrow.js').to_s}"></script>}
      end
    end

    get '/uborrow.html' do
      shim
    end
    
    options '/*' do
      response_headers = {
        'Content-Type' => 'text/html; charset-utf-8',
        'Access-Control-Allow-Origin'  => request.env['HTTP_ORIGIN'],
        'Access-Control-Allow-Methods' => request.env['HTTP_ACCESS_CONTROL_REQUEST_METHOD'],
        'Access-Control-Allow-Headers' => request.env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
      }.reject { |k,v| v.nil? }
      [200,response_headers,'']
    end

    post '/*' do
      payload = JSON.parse(request.body.read).merge(settings.required_fields)
      path = params[:splat].join('')
      response = RestClient.post "https://rc.relais-host.com/#{path}", payload.to_json, content_type: 'application/json'
      [200,{'Access-Control-Allow-Origin'=>'*'},response]
    end
  end
end
