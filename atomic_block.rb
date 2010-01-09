#!/usr/bin/env ruby
# Atomic Block by Henrik Nyh <http://henrik.nyh.se> 2010-01-06 under the MIT license.
# Atom (RSS) feed for Blocket.se searches.

%w[cgi iconv time date rubygems].each {|lib| require lib }

require "mechanize"  # sudo gem install mechanize
require('builder') rescue require('active_support')  # sudo gem install builder

USER_AGENT = WWW::Mechanize::AGENT_ALIASES['Windows IE 7']

# CET should be considered local time.
# Seems to work fine during daylight savings (CEST).
ENV['TZ'] = 'CET'


module Blocket

  class Item
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
        
    def to_atom(feed)
      feed.entry do |entry|

        entry.id      "#{Scraper.atom_namespace}:#{id}"
        entry.title   self.title
        entry.updated self.time.iso8601
        entry.link    :href => self.url
        
        data = []
        if self.price
          lowered_price = self.lowered_price? ? %[<b style="color:green">↘ Prissänkt</b>] : nil   # Unicode south-east arrow.
          data << ["<b>Pris:</b> #{self.price}", lowered_price].compact.join(" ")
        end
        data << %[<a href="#{self.url}"><img src="#{self.image_url}"></a>] if self.image_url
        entry.content data.map {|x| "<p>#{x}</p>" }.join, :type => 'html'
      end
    end
    
  protected

    def parse
      parse_time
      parse_image
      parse_subject
    end

    def parse_time
      raw_time = @tr.at('th.listing_thumbs_date').inner_html
      
      # FIXME: Weird issue where conversion is needed in dev but breaks in production.
      raw_time = latin_1_to_utf_8(raw_time) unless raw_time.include?("å")
      
      date, time = raw_time.strip.split('<br>')

      date =
        case date
        when "Idag": Date.today
        when "Igår": Date.today - 1  # Igår.
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
      raw_img = @tr.at('td.listing_thumbs_image img[alt="Bild"]') || @tr.at('td.listing_thumbs_image img[alt="Flera bilder"]')
      @thumb_url = raw_img && raw_img[:src]
    end
  
    def parse_subject
      raw_subject = @tr.at('td.thumbs_subject')
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
  

  class Scraper
    NAME = "Atomic Block"
    TAG_NAME = "atomic-block"
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

      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct! :xml, :version => "1.0" 
      xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do |feed|
        feed.title     @title
        feed.id        "#{self.class.atom_namespace}:#{@url}"
        feed.link      :href => @url
        feed.updated   updated_at
        feed.author    {|a| a.name 'Blocket.se' }
        feed.generator NAME, :version => VERSION
        %w[ads classifieds swedish].each {|cat| feed.category :term => cat }
        
        items.each do |item|
          item.to_atom(feed)
        end
      end
    end
    
  protected
  
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


if __FILE__ == $0 && ENV['REQUEST_URI']  # CGI access.

  path = ENV['REQUEST_URI'].split("/").last.to_s
  url = "http://www.blocket.se/#{path}"
  scraper = Blocket::Scraper.new(url)

  puts "Content-Type: application/atom+xml; charset=utf-8"
  puts
  puts scraper.to_atom

end
