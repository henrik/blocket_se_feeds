# encoding: utf-8

require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require "./blocket"

set :views, -> { root }

get "/" do
  @title = "Blocket.se RSS-feed"
  slim :index
end

get %r{\.png\z}i do
  halt 404, "no image for you!"
end

get %r{/(.+)} do
  url = "http://www.blocket.se#{request.fullpath}"
  content_type "application/atom+xml", charset: "utf-8"

  Blocket::Feeder.feed_with_single_entry(
    title: "No longer maintained",
    html_content: %{<p>Sorry, this service is no longer maintained.</p>},
  )
end
