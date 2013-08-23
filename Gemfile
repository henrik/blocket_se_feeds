source :rubygems

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

group :production do
  gem "unicorn"
  gem "newrelic_rpm"
end
