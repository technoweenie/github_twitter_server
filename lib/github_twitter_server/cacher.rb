require 'github_twitter_server/cacher/feed'
module GithubTwitterServer
  class Cacher
    attr_accessor :connection

    DEFAULT_HOST = "http://github.com".freeze

    def initialize(host = nil)
      @connection = GithubTwitterServer::Connection.new(host || DEFAULT_HOST)
    end

    def fetch_feed(path)
      atom_data = Feed.read(path) do
        resp = @connection.get(path)
        resp ? resp.body : nil
      end
      GithubTwitterServer::Feed.new(atom_data).entries.map do |entry|
        entry.twitter_status
      end
    end

    def fetch_user_feed(user)
      return [] if !user
      fetch_feed("#{user}.atom")
    end
  end
end