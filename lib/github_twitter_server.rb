require 'faraday'
module GithubTwitterServer
  autoload :Feed, "github_twitter_server/feed"

  class Connection < Faraday::Connection
    include Faraday::Adapter::Typhoeus.loaded? ? Faraday::Adapter::Typhoeus : Faraday::Adapter::NetHttp
  end
end