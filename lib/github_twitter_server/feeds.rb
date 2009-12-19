require 'sax-machine'
require 'faraday'
module GithubTwitterServer
  module Feeds
    autoload :UserFeed, "github_twitter_server/feeds/user_feed"
  end
end