# encoding: utf-8

require "date"
require "time"
require "nokogiri"

module Blocket
  class TimeParser
    CSS_DATE_AND_TIME = ".jlist_date_image, .list_date"
    CSS_TIME          = ".list_time"

    def initialize(fragment)
      @fragment = fragment
    end

    def to_time
      raw_date = html.children.first.inner_text.strip

      time = html.at(CSS_TIME)
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
        Time.parse("#{date} #{result.year-1} #{time}")
      else
        result
      end
    end

    private

    def html
      Nokogiri::HTML.fragment(@fragment).at(CSS_DATE_AND_TIME)
    end
  end
end
