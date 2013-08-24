# encoding: utf-8

require "timecop"
require_relative "../blocket/time_parser"

describe Blocket::TimeParser, "#to_time" do
  now = Time.new(2000, 12, 30, 12, 0)

  before { Timecop.freeze(now) }
  after { Timecop.return }

  it "handles 'Idag'" do
    assert_parse(html("Idag", "22:58"), "2000-12-30", "22:58:00")
  end

  it "handles 'Igår'" do
    assert_parse(html("Igår", "22:58"), "2000-12-29", "22:58:00")
  end

  %w[jan feb mar apr maj jun jul aug sep okt nov dec].each_with_index do |month, index|
    num = index + 1
    it "handles the month '#{month}'" do
      assert_parse(html("1 #{month}", "22:58"), "2000-#{"%02d" % num}-01", "22:58:00")
    end
  end

  it "assumes last year for a future date" do
    assert_parse(html("31 dec", "22:58"), "1999-12-31", "22:58:00")
  end

  it "handles < 12h times" do
    assert_parse(html("1 jan", "01:23"), "2000-01-01", "01:23:00")
  end

  it "handles the real estate listing time format" do
    html = %{<div class="jlist_date_image">22 aug <span class="list_date">18:03</span></div>}
    assert_parse(html, "2000-08-22", "18:03:00")
  end

  it "handles another real estate listing time format" do
    html = %{<div class="jlist_date_image">22 aug <span class="time">18:03</span></div>}
    assert_parse(html, "2000-08-22", "18:03:00")
  end

  def assert_parse(html, date, time)
    actual = described_class.new(html).to_time
    actual.to_date.to_s.should == date
    actual.strftime("%H:%M:%S").should == time
  end

  def html(date, time)
      %{<div class="desc"><div class="list_date">#{date} <span class="list_time">#{time}</span></div>}
  end
end
