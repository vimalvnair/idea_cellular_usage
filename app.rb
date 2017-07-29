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
  set :database, {adapter: "sqlite3", database: "some.sqlite3"}
end


class Session < ActiveRecord::Base
end
  
get '/' do
  content_type :json
  usage = get_usage(ENV['MOBILE'], ENV['PASSWORD'])
  usage.to_json
end
