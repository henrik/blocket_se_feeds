# encoding: utf-8

require "date"
require "time"
require "nokogiri"

module Blocket
  class TimeParser
    def initialize(fragment)
      @fragment = fragment
    end

    def to_time
      Time.parse(time_string)
    end

    private

    def time_string
      doc.at("time")[:datetime]
    end

    def doc
      Nokogiri::HTML.fragment(@fragment)
    end
  end
end
