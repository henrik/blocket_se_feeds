# encoding: utf-8

require_relative "blocket"
require "rubygems"
require "sinatra"

get '/' do
  %{
    <!DOCTYPE html>
    <html lang="sv">
      <meta charset="UTF-8">
      <head><title>Blocket.se RSS-feed</title></head>
      <body>
        <h1>Blocket.se RSS-feed</h1>
        <p>Följ Blockets annonser med RSS<a href="#footnote">*</a>.</p>
        <p>Gör en sökning på Blocket och byt sen ut <code>www.blocket.se</code> i adresssen mot <code>#{request.host_with_port}</code> så har du en feed.</p>
        <p>
          T.ex. när du är på <code>http://<strong>www.blocket.se</strong>/stockholm?q=fisk</code>, ändra till
          <code>http://<strong>#{request.host_with_port}</strong>/stockholm?q=fisk</code>.
        </p>
        <p>
          Eller bokmärk denna bookmarklet för att ändra med ett klick:
          <a href="javascript:location.href=location.href.replace('www.blocket.se', '#{request.host_with_port}');">Blocket RSS</a>
        </p>
        <p>
          Koden kan sättas upp på en annan server om Blocket blockerar denna.
          <a href="http://github.com/henrik/blocket_se_feeds">Visa källa.</a>
        </p>
        <p>Av <a href="http://henrik.nyh.se">Henrik Nyh</a>.</p>
        <hr>
        <p><span id="footnote">*</span> Tekniskt sett är det Atom, men det funkar likadant.</p>
      </body>
    </html>
  }
end

get %r{/(.+)} do
  url = "http://www.blocket.se#{request.fullpath}"
  content_type 'application/atom+xml', :charset => 'utf-8'
  begin
    heroku_timeout do
      Blocket::ScraperFeeder.new(url).to_atom
    end
  rescue => e
    Blocket::ScraperFeeder.render_exception(e)
  end
end

# http://adam.heroku.com/past/2008/6/17/battling_wedged_mongrels_with_a/
def heroku_timeout
  require "timeout"
  Timeout.timeout(10) do
    yield
  end
end
