require "blocket"
require "rubygems"
require "sinatra"

get '/' do
  %{
    <!DOCTYPE html>
    <html>
      <head><title>Blocket.se Feeds</title></head>
      <body>
        <h1>Blocket.se Feeds</h1>
        <p>Provides an Atom (RSS, kind of) feed of Blocket.se search results. Blocket.se is a Swedish classifieds site.</p>
        <p>E.g. for a feed of <code>http://www.blocket.se/stockholm?q=fisk</code>, visit:</p>
        <p><code>http://#{request.host_with_port}/stockholm?q=fisk</code></p>
        <p>You can set this up on another server if Blocket bans it. <a href="http://github.com/henrik/blocket_se_feeds">View source.</a></p>
        <p>By <a href="http://henrik.nyh.se">Henrik Nyh</a>.</p>
      </body>
    </html>
  }
end

get %r{/(.+)} do
  url = "http://www.blocket.se#{request.fullpath}"
  content_type 'application/atom+xml', :charset => 'utf-8'
  begin
    Blocket::ScraperFeeder.new(url).to_atom
  rescue => e
    Blocket::ScraperFeeder.render_exception(e)
  end
end
