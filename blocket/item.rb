# encoding: utf-8

require "date"
require "time"

module Blocket
  class Item
    CSS_DATE_AND_TIME = ".jlist_date_image, .list_date"
    CSS_TIME          = ".list_time"
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
      date_and_time = @row.at(CSS_DATE_AND_TIME)

      raw_date = date_and_time.children.first.inner_text.strip

      time = @row.at(CSS_TIME)
      raw_time = time.inner_text


      date =
        case raw_date
        when "Idag"
          Date.today
        when "Igår"
          Date.today - 1
        when /okt/
          raw_date.sub(/okt/, 'oct')
        when /maj/
          raw_date.sub(/maj/, 'may')
        else
          raw_date
        end

      result = Time.parse("#{date} #{time}")

      if result > Time.now  # Future date? Then it was really last year.
        result = Time.parse("#{date} #{result.year-1} #{time}")
      end

      @time = result
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
