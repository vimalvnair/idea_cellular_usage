require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require 'pg'
require "nokogiri"
require 'net/http'
require 'yaml'
require_relative './idea_usage_fetcher'

include IdeaCellular

configure :production do
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: ENV['DB_NAME'], pool: 2, username: ENV['DB_USER'], password: ENV['DB_PASSWORD'], port: ENV['DB_PORT']}
end

configure :development do
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'your_database_name', pool: 2, username: 'your_username', password: 'your_password'}
end

#if ENV['DATABASE_URL']
#  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
#else
#end


class Session < ActiveRecord::Base
end
  
get '/' do
  content_type :json
  usage = get_usage(ENV['MOBILE'], ENV['PASSWORD'])
  usage.to_json
end
