require('builder') rescue require('active_support')  # sudo gem install builder

module Blocket
  class Feeder
    NAME = "Blocket.se Feeds"
    TAG_NAME = "blocket-se-feeds"
    VERSION = "1.0"
    SCHEMA_DATE = "2010-01-06"

    attr_reader :title, :items

    def initialize(scraper)
      @scraper = scraper
    end

    def to_atom
      updated_at = items.first ? items.first.time : Time.now
      self.class.feed(title: title, url: url, updated_at: updated_at) do |feed|
        items.each do |item|
          self.class.feed_entry(feed, item.to_hash)
        end
      end
    end

    def self.render_exception(e)
      self.feed(title: "Blocket.se", url: GITHUB_URL, updated_at: Time.now) do |feed|
        self.feed_entry(feed,
          id: 'exception',
          title: "Scraper exception!",
          updated_at: Time.now,
          url: GITHUB_URL,
          content: "<h1>#{e.class.name}: #{e.message}</h1><p>#{e.backtrace}</p>"
        )
      end
    end

    private

    def title
      @scraper.title
    end

    def url
      @scraper.url
    end

    def items
      @scraper.items
    end

    def self.feed(opts = {})
      url = opts[:url]

      xml = Builder::XmlMarkup.new(indent: 2)
      xml.instruct! :xml, version: "1.0"
      xml.feed(xmlns: "http://www.w3.org/2005/Atom") do |feed|
        feed.title     opts[:title]
        feed.id        "#{self.atom_namespace}:#{url}"
        feed.link      href: url
        feed.updated   opts[:updated_at].iso8601
        feed.author    {|a| a.name 'Blocket.se' }
        feed.generator NAME, version: VERSION
        %w[ads classifieds swedish].each {|cat| feed.category term: cat }
        yield(feed)
      end
    end

    def self.feed_entry(feed, opts={})
      feed.entry do |entry|
        entry.id      "#{self.atom_namespace}:#{opts[:id]}"
        entry.title   opts[:title]
        entry.updated opts[:updated_at].iso8601
        entry.link    href: opts[:url]
        entry.content opts[:content], type: 'html'
      end
    end

    def self.atom_namespace
      "tag:#{TAG_NAME},#{SCHEMA_DATE}"
    end
  end
end
