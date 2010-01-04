$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'friendly', 'lib')

require 'alice'
require 'friendly'

module GithubTwitterServer
  autoload :Feed,   "github_twitter_server/feed"
  autoload :Cacher, "github_twitter_server/cacher"

  def self.new_connection(*args)
    Alice::Connection.new(*args) do
      adapter :net_http
    end
  end
end
