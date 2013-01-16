# Blocket.se Feeds by Henrik Nyh <http://henrik.nyh.se> 2010-01-06 under the MIT license.
# Atom (RSS) feed for Blocket.se searches.

require "cgi"

# CET should be considered local time.
# Seems to work fine during daylight savings (CEST).
ENV['TZ'] = 'CET'

require_relative "blocket/item"
require_relative "blocket/scraper_feeder"

module Blocket
  GITHUB_URL = "http://github.com/henrik/blocket_se_feeds"
end


if __FILE__ == $0
  if ENV['REQUEST_URI']  # CGI access.
    path = ENV['REQUEST_URI'].split("/").last.to_s
    url = "http://www.blocket.se/#{path}"

    puts "Content-Type: application/atom+xml; charset=utf-8"
    puts

    begin
      puts Blocket::ScraperFeeder.new(url).to_atom
    rescue => e
      puts Blocket::ScraperFeeder.render_exception(e)
    end
  else  # Command line, to debug
    url = "http://www.blocket.se/stockholm?q=bokhylla"
    url = "http://www.blocket.se/stockholm/bostad?ca=11&w=1&cg=3000&st=a"
    scraper = Blocket::ScraperFeeder.new(url)
    puts scraper.to_atom
  end
end
