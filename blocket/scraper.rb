require "mechanize"  # sudo gem install mechanize

module Blocket
  class Scraper
    class PageNotFoundError < StandardError; end
    class EncodingError < StandardError; end

    USER_AGENT = Mechanize::AGENT_ALIASES['Windows IE 10']
    CSS_QUERY = "#searchtext"
    CSS_ITEM  = ".item_row"

    attr_reader :title, :items

    def initialize(url)
      @url = url
    end

    def run
      raise_on_404 do
        a = Mechanize.new { |agent| agent.user_agent = USER_AGENT }
        @page = a.get(url)
        parse_title
        parse_items
      end
    end

    def url
      fix_params(fix_encoding(@url))
    end

    private

    def raise_on_404
      yield
    rescue Mechanize::ResponseCodeError => e
      if e.message.include?("404")
        raise PageNotFoundError
      else
        raise
      end
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
      @conversion_attempts ||= 0
      @conversion_attempts += 1
      URI.encode(URI.decode(url).encode("ISO-8859-1"))
    rescue Encoding::UndefinedConversionError => e
      if @conversion_attempts > 1
        raise EncodingError.new("Error converting #{url.inspect} - original error: #{e.message}")
      end
      # Assume the input was unencoded Latin-1.
      convert_to_latin_1(url.force_encoding("ISO-8859-1"))
    end

    def fix_params(url)
      url.
        sub(/&o=\d+/, "&o=1").     # Always show first page.
        sub(/&md=\w+/, "&md=th").  # Always show thumbs.
        sub(/&sp=\d+/, "&sp=0")    # Always sort by date.
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
  end
end
