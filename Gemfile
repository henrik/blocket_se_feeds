source "https://rubygems.org"

ruby "2.1.1"

gem "rack-canonical-host"
gem "sinatra"
gem "slim"
gem "rdiscount"
gem "mechanize"
gem "builder"
gem "dalli"
gem "rack-cache"
gem "raygun4ruby"

# Rewrites Heroku ENV names so Dalli just works.
gem "memcachier"

gem "rake"

group :test do
  gem "rspec"
  gem "rack-test"
  gem "timecop"
end

group :production do
  gem "unicorn"
  gem "newrelic_rpm"
end
