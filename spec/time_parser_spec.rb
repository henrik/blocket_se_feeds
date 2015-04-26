# encoding: utf-8

require "timecop"
require_relative "../blocket/time_parser"

describe Blocket::TimeParser, "#to_time" do
  now = Time.new(2000, 12, 30, 12, 0)

  before { Timecop.freeze(now) }
  after { Timecop.return }

  it "parses the time" do
    fragment = %{<article>
      <time datetime="2015-04-24 19:27:42" pubdate="" itemprop="datePublished" class="pull-right">24 apr  19:27</time>
    </article>}

    result = Blocket::TimeParser.new(fragment).to_time

    result.should == Time.new(2015, 4, 24,  19, 27, 42)
  end
end
