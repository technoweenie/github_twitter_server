require 'alice'
require 'friendly'
require "github_twitter_server/cacher/postgres"

module GithubTwitterServer
  autoload :Feed,   "github_twitter_server/feed"
  autoload :Cacher, "github_twitter_server/cacher"

  def self.new_connection(*args)
    Alice::Connection.new(*args) do
      adapter :net_http
    end
  end
end
