# encoding: utf-8

require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require "./rack_cache_patch"
require "./blocket"

set :views, -> { root }

get "/" do
  @title = "Blocket.se RSS-feed"
  slim :index
end

get %r{/(.+)} do
  url = "http://www.blocket.se#{request.fullpath}"
  content_type "application/atom+xml", charset: "utf-8"

  heroku_timeout do
    body = Blocket::ScraperFeeder.new(url).to_atom
    # Only if body didn't time out. Don't cache errors.
    unless params[:nocache]
      cache_control :public, max_age: 1800  # 30 mins.
    end
    body
  end
rescue Blocket::Scraper::PageNotFoundError
  halt 404, "No such page."
rescue Timeout::Error
  halt 504, "Timeout."
rescue => e
  render_exception(e)
end

def render_exception(e)
  # debug issue
  if e.message.include?("Mechanize::Image")
    debug_e = StandardError.new("#{e.class} #{e.message} [ PATH #{request.fullpath} ]")
    e = debug_e
  end

  track_exception(e)
  Blocket::ScraperFeeder.render_exception(e)
end

def track_exception(e)
  Raygun.track_exception(e)
end

# http://adam.heroku.com/past/2008/6/17/battling_wedged_mongrels_with_a/
def heroku_timeout
  require "timeout"
  Timeout.timeout(10) do
    yield
  end
end
