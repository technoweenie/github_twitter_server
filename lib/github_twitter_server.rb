$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'friendly', 'lib')

require 'faraday'
require 'friendly'

module GithubTwitterServer
  autoload :Feed,   "github_twitter_server/feed"
  autoload :Cacher, "github_twitter_server/cacher"

  class Connection < Faraday::Connection
    include Faraday::Adapter::NetHttp
  end
end
