# encoding: utf-8

require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require "./rack_cache_patch"
require "./blocket"

set :views, -> { root }

get '/' do
  @title = "Blocket.se RSS-feed"
  slim :index
end

get %r{/(.+)} do
  url = "http://www.blocket.se#{request.fullpath}"
  content_type "application/atom+xml", charset: "utf-8"
  begin
    heroku_timeout do
      body = Blocket::ScraperFeeder.new(url).to_atom
      # Only if body didn't time out. Don't cache errors.
      cache_control :public, max_age: 1800  # 30 mins.
      body
    end
  rescue => e
    Blocket::ScraperFeeder.render_exception(e)
  end
end

# http://adam.heroku.com/past/2008/6/17/battling_wedged_mongrels_with_a/
def heroku_timeout
  require "timeout"
  Timeout.timeout(10) do
    yield
  end
end
