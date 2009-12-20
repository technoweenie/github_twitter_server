require 'faraday'
module GithubTwitterServer
  autoload :Feed, "github_twitter_server/feed"

  STATUS = {:source => 'github', :source_href => 'http://github.com'}.freeze

  class Connection < Faraday::Connection
    include Faraday::Adapter::Typhoeus.loaded? ? Faraday::Adapter::Typhoeus : Faraday::Adapter::NetHttp
  end
end