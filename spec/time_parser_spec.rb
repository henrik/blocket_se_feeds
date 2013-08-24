# encoding: utf-8

require_relative "../blocket/time_parser"

describe Blocket::TimeParser, "#to_time" do
  it "works" do
    assert_parses_into (Date.today - 1), "22:58:00",
      %{<div class="desc"><div class="list_date">Igår <span class="list_time">22:58</span></div>}
  end

  def assert_parses_into(date, time, html)
    actual = described_class.new(html).to_time
    actual.to_date.should == date
    actual.strftime("%H:%M:%S").should == time
  end
end
