# encoding: utf-8

require "date"
require "time"

require_relative "time_parser"

module Blocket
  class Item
    CSS_SUBJECT       = ".desc"
    CSS_IMAGE         = ".image_content img"
    # Real estate listings, other listings.
    CSS_PRICE         = "span[itemprop=price], .list_price"
    CSS_LOWERED_PRICE = "img.sprite_list_icon_price_arrow"

    attr_reader :id, :time, :thumb_url, :url, :title, :price

    def initialize(row)
      @row = row
      parse
    end

    def image_url
      @thumb_url && @thumb_url.sub("/lithumbs", "/images")
    end

    def mobile_url
      url.sub("//www.", "//mobil.")
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
      data << %[<a href="#{self.url}">Full sajt</a> &nbsp;|&nbsp; <a href="#{self.mobile_url}">Mobil sajt</a>]
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
      parse_subject
      parse_time
      parse_image
    end

    def parse_time
      fragment = @row.to_html
      @time = TimeParser.new(fragment).to_time
    end

    def parse_image
      if raw_img = @row.at(CSS_IMAGE)
        # Lazy-loaded images put the src in longdesc.
        @thumb_url = raw_img[:longdesc] || raw_img[:src]
      end
    end

    def parse_subject
      raw_subject = @row.at(CSS_SUBJECT)
      a = raw_subject.at('a')
      @url = a[:href]
      @title = a.inner_text.strip
      @id = @url[/(\d+)\.htm/, 1]

      if raw_price = raw_subject.at(CSS_PRICE)
        @price = raw_price.inner_text.strip
        @price = nil if @price.empty?
      end

      @lowered_price = raw_subject.at(CSS_LOWERED_PRICE) != nil
    end
  end
end
