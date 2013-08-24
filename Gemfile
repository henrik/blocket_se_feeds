source "https://rubygems.org"

ruby "1.9.3"

gem "rack-canonical-host"
gem "sinatra"
gem "slim"
gem "rdiscount"
gem "mechanize"
gem "builder"
gem "dalli"
gem "rack-cache"

# Rewrites Heroku ENV names so Dalli just works.
gem "memcachier"

group :development do
  gem "rake"
end

group :test do
  gem "rspec"
  gem "rack-test"
end

group :production do
  gem "unicorn"
  gem "newrelic_rpm"
end
