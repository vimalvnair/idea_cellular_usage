require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require "nokogiri"
require 'net/http'
require 'yaml'
require_relative './idea_usage_fetcher'

include IdeaCellular

set :database, {adapter: "sqlite3", database: "some.sqlite3"}
set :port, 6060

class Session < ActiveRecord::Base
end
  
get '/' do
  content_type :json
  usage = get_usage(ENV['MOBILE'], ENV['PASSWORD'])
  usage.to_json
end
