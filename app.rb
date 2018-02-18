require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require "nokogiri"
require 'net/http'
require 'yaml'
require_relative './idea_usage_fetcher'

include IdeaCellular

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'your_database_name', pool: 2, username: 'your_username', password: 'your_password'}
end


class Session < ActiveRecord::Base
end
  
get '/' do
  content_type :json
  usage = get_usage(ENV['MOBILE'], ENV['PASSWORD'])
  usage.to_json
end
