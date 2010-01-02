require File.dirname(__FILE__) + "/../lib/github_twitter_server/api.rb"
Friendly.configure ENV['DATABASE_URL']

set :run, false

run Sinatra::Application