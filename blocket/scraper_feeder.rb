require_relative "item"
require_relative "scraper"
require_relative "feeder"

module Blocket
  class ScraperFeeder
    def initialize(url)
      @scraper = Scraper.new(url)
      @scraper.run
      @feeder = Feeder.new(@scraper)
    end

    def to_atom
      @feeder.to_atom
    end

    def self.render_exception(e)
      Feeder.render_exception(e)
    end
  end
end
