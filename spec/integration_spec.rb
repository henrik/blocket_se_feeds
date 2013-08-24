ENV['RACK_ENV'] = "test"

require_relative "../app"

describe "The app" do
  include Rack::Test::Methods

  describe "start page" do
    it "works" do
      get "/"
      last_response.should be_ok
      last_response.body.should include "<h1>Blocket"
    end
  end

  describe "feed" do
    it "works with a simple query" do
      assert_feed_for "/stockholm?q=fisk"
    end

    it "works with a Latin-1 query" do
      assert_feed_for "/goteborg?q=sk%E5p&cg=0&w=1&st=s&ca=15&is=1&l=0&md=th"
    end

    it "works with a UTF-8 query" do
      assert_feed_for "/goteborg?q=sk%C3%A5p&cg=0&w=1&st=s&ca=15&is=1&l=0&md=th"
    end

    it "works with real estate" do
      assert_feed_for "/bostad/uthyres/lagenheter/stockholm?q=&sort=&ss=4&se=&ros=3&roe=&mre=&is=1&l=0&md=th&as=131_4&as=131_6&as=131_7&as=131_9&as=131_11"
    end
  end

  def assert_feed_for(path)
    get path
    last_response.should be_ok
    last_response.headers["Content-Type"].should include "application/atom+xml"
    last_response.body.should include "<entry>"
    last_response.body.should_not include "Scraper exception"
  end

  def app
    Sinatra::Application
  end
end
