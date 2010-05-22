#!/usr/bin/env ruby
# Blocket.se Feeds by Henrik Nyh <http://henrik.nyh.se> 2010-01-06 under the MIT license.
# Atom (RSS) feed for Blocket.se searches.

%w[cgi iconv time date rubygems].each {|lib| require lib }

require "mechanize"  # sudo gem install mechanize
require('builder') rescue require('active_support')  # sudo gem install builder

# CET should be considered local time.
# Seems to work fine during daylight savings (CEST).
ENV['TZ'] = 'CET'

USER_AGENT = WWW::Mechanize::AGENT_ALIASES['Windows IE 7']


module Blocket

  GITHUB_URL = "http://github.com/henrik/blocket_se_feeds"

  class Item
    
    CSS_DATE    = "th.listing_lithumbs_date"
    CSS_SUBJECT = "td.lithumbs_subject"
    CSS_IMAGE   = "td.listing_lithumbs_image"
    
    attr_reader :id, :time, :thumb_url, :url, :title, :price

    def initialize(tr)
      @tr = tr
      parse
    end
  
    def image_url
      @thumb_url && @thumb_url.sub('/thumbs', '/images')
    end
    
    def lowered_price?
      @lowered_price
    end
        
    def to_hash
      data = []
      if self.price
        lowered_price = self.lowered_price? ? %[<b style="color:green">↘ Prissänkt</b>] : nil   # Unicode south-east arrow.
        data << ["<b>Pris:</b> #{self.price}", lowered_price].compact.join(" ")
      end
      data << %[<a href="#{self.url}"><img src="#{self.image_url}"></a>] if self.image_url
      content = data.map {|x| "<p>#{x}</p>" }.join
    
      {
        :id      => id,
        :title   => self.title,
        :updated => self.time,
        :url     => self.url,
        :content => content
      }
    end
    
  protected

    def parse
      parse_time
      parse_image
      parse_subject
    end

    def parse_time    
      raw_time = @tr.at(CSS_DATE).inner_html
      
      # FIXME: Weird issue where conversion is needed in dev but breaks in production.
      raw_time = latin_1_to_utf_8(raw_time) unless raw_time.include?("å")
      
      date, time = raw_time.strip.split('<br>')

      date =
        case date
        when "Idag": Date.today
        when "Igår": Date.today - 1
        when /okt/:  date.sub(/okt/, 'oct')
        when /maj/:  date.sub(/maj/, 'may')
        else         date
        end

      result = Time.parse("#{date} #{time}")

      if result > Time.now  # Future date? Then it was really last year.
        result = Time.parse("#{date} #{result.year-1} #{time}")
      end
    
      @time = result
    end
  
    def parse_image
      raw_img = @tr.at("#{CSS_IMAGE} img[alt='Bild']") || @tr.at("#{CSS_IMAGE} img[alt='Flera bilder']")
      @thumb_url = raw_img && raw_img[:src]
    end
  
    def parse_subject
      raw_subject = @tr.at(CSS_SUBJECT)
      a = raw_subject.at('a')    
      @url = a[:href]
      @title = a.inner_text.strip
      @id = @url[/(\d+)\.htm/, 1]

      raw_price = latin_1_to_utf_8(raw_subject.inner_html.split('<br>', 2).last)
      price_fragment = Nokogiri::HTML.fragment(raw_price)
      @price = price_fragment.inner_text.strip
      @price = nil if @price.empty?

      @lowered_price = !!raw_subject.at('img[alt="Prissänkt"]')
    end
  
    def latin_1_to_utf_8(text)
      Iconv.new('utf-8', 'iso-8859-1').iconv(text)
    end

  end
  

  class ScraperFeeder
    NAME = "Blocket.se Feeds"
    TAG_NAME = "blocket-se-feeds"
    VERSION = "1.0"
    SCHEMA_DATE = "2010-01-06"
    
    attr_reader :title, :items
    
    def self.atom_namespace
      "tag:#{TAG_NAME},#{SCHEMA_DATE}"
    end
    
    def initialize(url)
      @url = url.
        sub(/&o=\d+/, "&o=1").     # Always show first page.
        sub(/&md=\w+/, "&md=th").  # Always show thumbs.
        sub(/&sp=\d+/, "&sp=0")    # Always sort by date.
      a = WWW::Mechanize.new { |agent| agent.user_agent = USER_AGENT }
      @page = a.get(@url)
      parse_title
      parse_items
    end
    
    def to_atom
      updated_at = (items.first ? items.first.time : Time.now).iso8601
      self.class.feed(:title => @title, :url => @url, :updated_at => updated_at) do |feed|      
        items.each do |item|
          self.class.feed_entry(feed, item.to_hash)
        end
      end
    end
    
    def self.render_exception(e)
      self.feed(:title => "Blocket.se", :url => GITHUB_URL, :updated_at => Time.now) do |feed|
        self.feed_entry(feed,
          :id      => 'exception',
          :title   => "Scraper exception!",
          :updated => Time.now,
          :url     => GITHUB_URL,
          :content => "<h1>#{e.message}</h1><p>#{e.backtrace}</p>"
        )
      end
    end
    
  protected
  
    def self.feed(opts={})
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct! :xml, :version => "1.0" 
      xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do |feed|
        feed.title     opts[:title]
        feed.id        "#{self.atom_namespace}:#{opts[:url]}"
        feed.link      :href => opts[:url]
        feed.updated   opts[:updated_at]
        feed.author    {|a| a.name 'Blocket.se' }
        feed.generator NAME, :version => VERSION
        %w[ads classifieds swedish].each {|cat| feed.category :term => cat }
        yield(feed)
      end
    end
    
    def self.feed_entry(feed, opts={})
      feed.entry do |entry|
        entry.id      "#{self.atom_namespace}:#{opts[:id]}"
        entry.title   opts[:title]
        entry.updated opts[:updated].iso8601
        entry.link    :href => opts[:url]
        entry.content opts[:content], :type => 'html'
      end
    end
  
    def parse_title
      title = @page.title
      query = @page.at('#searchtext')[:value] rescue ""
      @title = [query, title].map {|s| s.strip }.reject {|s| s.empty? }.join(' | ')
    end
    
    def parse_items
      if table = @page.at('table.listing_thumbs')
        @items = table.children.map { |tr| Blocket::Item.new(tr) }
      else
        @items = []
      end
    end
    
  end


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
    scraper = Blocket::ScraperFeeder.new(url)
    puts scraper.to_atom
    
  end

end
