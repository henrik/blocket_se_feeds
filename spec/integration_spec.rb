ENV['RACK_ENV'] = "test"

require_relative "../app"

describe "The app" do
  include Rack::Test::Methods

  describe "start page" do
    before { get "/" }

    it "works" do
      last_response.should be_ok
      last_response.body.should include "<h1>Blocket"
    end
  end

  describe "query" do
    it "works with a simple query" do
      assert_feed_for "/stockholm?q=fisk"
    end

    it "works with a Latin-1 query" do
      assert_feed_for "/goteborg?q=sk%E5p&cg=0&w=1&st=s&ca=15&is=1&l=0&md=th"
    end
  end

  def assert_feed_for(path)
    get path
    last_response.should be_ok
    last_response.headers["Content-Type"].should include "application/atom+xml"
    last_response.body.should include "<entry>"
  end


  def app
    Sinatra::Application
  end
end
