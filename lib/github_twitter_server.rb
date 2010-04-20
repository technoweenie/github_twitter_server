$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'friendly', 'lib')

require 'faraday'
require 'friendly'

module GithubTwitterServer
  autoload :Feed,   "github_twitter_server/feed"
  autoload :Cacher, "github_twitter_server/cacher"

  def self.new_connection(*args)
    Faraday::Connection.new(*args) do |b|
      b.adapter :net_http
    end
  end
end
