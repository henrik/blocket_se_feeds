# encoding: utf-8

require "date"
require "time"

require_relative "time_parser"

module Blocket
  class Item
    #                   regular             bostad
    CSS_SUBJECT       = "h1[itemprop=name], .media-heading"
    CSS_IMAGE         = ".item_image,       a.media-object"
    CSS_PRICE         = "[itemprop=price]"
    CSS_LOWERED_PRICE = ".blocket-icon-price-lowered"

    # Only bostad has this now.
    CSS_DESC          = ".details"

    attr_reader :id, :time, :thumb_url, :url, :title, :price, :details, :desc

    def initialize(row)
      @row = row
      parse
    end

    def image_url
      @thumb_url && @thumb_url.sub("/lithumbs", "/images")
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
      if self.details
        data << self.details.join(" | ")
      end
      data << self.desc if self.desc
      data << %[<a href="#{self.url}"><img src="#{self.image_url}"></a>] if self.image_url
      content = data.map {|x| "<p>#{x}</p>" }.join

      {
        id: id,
        title: self.title,
        updated_at: self.time,
        url: self.url,
        content: content
      }
    end

    private

    def parse
      parse_subject_and_id_and_url
      parse_price
      parse_time
      parse_image
      parse_description
    end

    def parse_subject_and_id_and_url
      raw_subject = @row.at(CSS_SUBJECT)
      a = raw_subject.at('a')
      @url = a[:href]
      @title = node_content(a)
      @id = @url[/(\d+)\.htm/, 1]
    end

    def parse_price
      if raw_price = @row.at(CSS_PRICE)
        @price = node_content(raw_price)
        @price = nil if @price.empty?
      end

      @lowered_price = @row.at(CSS_LOWERED_PRICE) != nil
    end

    def parse_time
      fragment = @row.to_html
      @time = TimeParser.new(fragment).to_time
    end

    def parse_image
      if raw_img = @row.at(CSS_IMAGE)
        # Lazy-loaded images put the src in longdesc.
        # Property listings use a CSS background-image.
        @thumb_url =
          raw_img[:longdesc] ||
          raw_img[:src] ||
          raw_img[:style].to_s[/url\((.+?)\)/, 1]
      end
    end

    def parse_description
      node = @row.at(CSS_DESC)
      @desc = node_content(node)
    end

    def node_content(node)
      node && node.inner_text.strip
    end
  end
end
