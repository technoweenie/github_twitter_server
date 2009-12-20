require File.dirname(__FILE__) + "/../lib/github_twitter_server/api.rb"

set :run, false
set :env, ENV['APP_ENV'] || :production

run Sinatra::Application
