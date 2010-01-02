require File.dirname(__FILE__) + "/../lib/github_twitter_server/api.rb"
require File.dirname(__FILE__) + "/../lib/github_twitter_server/cacher/postgres.rb"
Friendly.configure ENV['DATABASE_URL']

set :run, false

run Sinatra::Application