require "rubygems"
require "mechanize"  # sudo gem install mechanize
require('builder') rescue require('active_support')  # sudo gem install builder

module Blocket
  class ScraperFeeder
    USER_AGENT = Mechanize::AGENT_ALIASES['Windows IE 7']
    NAME = "Blocket.se Feeds"
    TAG_NAME = "blocket-se-feeds"
    VERSION = "1.0"
    SCHEMA_DATE = "2010-01-06"

    CSS_QUERY = "#searchtext"
    CSS_ITEM  = ".item_row"

    attr_reader :title, :items

    def self.atom_namespace
      "tag:#{TAG_NAME},#{SCHEMA_DATE}"
    end

    def initialize(url)
      @url = url
    end

    def to_atom
      run

      updated_at = items.first ? items.first.time : Time.now
      self.class.feed(title: @title, url: url, updated_at: updated_at) do |feed|
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

    def url
      fix_params(fix_encoding(@url))
    end

    # Blocket needs Latin-1, at least in some cases.
    # We want to also support manually constructed URLs with UTF-8.
    def fix_encoding(url)
      convert_to_latin_1(url)
    rescue Encoding::InvalidByteSequenceError
      # It was Latin-1 already.
      url
    end

    def convert_to_latin_1(url)
      URI.encode(URI.decode(url).encode("ISO-8859-1"))
    end

    def fix_params(url)
      url.
        sub(/&o=\d+/, "&o=1").     # Always show first page.
        sub(/&md=\w+/, "&md=th").  # Always show thumbs.
        sub(/&sp=\d+/, "&sp=0")    # Always sort by date.
    end

    def run
      a = Mechanize.new { |agent| agent.user_agent = USER_AGENT }
      @page = a.get(url)
      parse_title
      parse_items
    end

    def parse_title
      title = @page.title
      raw_query = @page.at(CSS_QUERY)
      query = raw_query ? raw_query[:value] : ""
      @title = [query, title].map { |s| s.strip }.reject { |s| s.empty? }.join(" | ")
    end

    def parse_items
      @items = @page.parser.css(CSS_ITEM).map { |row| Blocket::Item.new(row) }
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
  end
end
