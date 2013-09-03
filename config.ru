require "./app"
require "./raygun_rack"

use Rack::CanonicalHost, ENV["CANONICAL_HOST"] if ENV["CANONICAL_HOST"]

# Defined in ENV on Heroku. To try locally, start memcached and uncomment:
# ENV['MEMCACHE_SERVERS'] = "localhost"  # DO NOT COMMIT
if memcache_servers = ENV['MEMCACHE_SERVERS']
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_servers}",
    entitystore: "memcached://#{memcache_servers}"
end


raygun_api_key = ENV['RAYGUN_API_KEY']

Raygun.setup do |config|
  config.api_key = raygun_api_key
  config.silence_reporting = !raygun_api_key
end

use RaygunRack


run Sinatra::Application
