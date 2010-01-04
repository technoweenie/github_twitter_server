require 'faraday'
require 'friendly'
module GithubTwitterServer
  autoload :Feed,   "github_twitter_server/feed"
  autoload :Cacher, "github_twitter_server/cacher"

  def self.new_connection(*args)
    Connection.new(*args)
  end

  class Connection < Faraday::Connection
    include Faraday::Adapter::Typhoeus.loaded? ? Faraday::Adapter::Typhoeus : Faraday::Adapter::NetHttp
  end
end