# encoding: utf-8

require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

# Defined in ENV on Heroku. To try locally, start memcached and uncomment:
# ENV['MEMCACHE_SERVERS'] = "localhost"
if memcache_servers = ENV['MEMCACHE_SERVERS']
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_servers}",
    entitystore: "memcached://#{memcache_servers}"
end

require "./blocket"

get '/' do
  %{
    <!DOCTYPE html>
    <html lang="sv">
      <meta charset="UTF-8">
      <head><title>Blocket.se RSS-feed</title></head>
      <body>
        <h1>Blocket.se RSS-feed</h1>
        <p>Följ Blockets annonser med RSS<a href="#footnote">*</a>.</p>
        <p>Gör en sökning på Blocket och byt sen ut <code>www.blocket.se</code> i adressen mot <code>#{request.host_with_port}</code> så har du en feed.</p>
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
      body = Blocket::ScraperFeeder.new(url).to_atom
      # Only if body didn't time out. Don't cache errors.
      cache_control :public, max_age: 1800  # 30 mins.
      body
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
