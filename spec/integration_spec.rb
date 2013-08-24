ENV['RACK_ENV'] = "test"

require_relative "../app"

describe "The app" do
  include Rack::Test::Methods

  describe "/" do
    before { get "/" }

    it "works" do
      last_response.should be_ok
      last_response.body.should include "<h1>Blocket"
    end
  end

  def app
    Sinatra::Application
  end
end
