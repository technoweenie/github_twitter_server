module GithubTwitterServer
  module Feeds
    class UserFeed
      attr_reader :feed_connection

      def initialize(connection, user)
        @atom = nil
        @feed_connection = connection
        @user = user
        @feed_url = nil
      end

      def atom_response
        @feed_connection.get(feed_url)
      end

      def feed_url
        @feed_url ||= "#{@user}.atom"
      end
    end
  end
end