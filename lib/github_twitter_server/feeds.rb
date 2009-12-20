require 'time'
require 'sax-machine'
require 'faraday'

module GithubTwitterServer
  module Feeds
    autoload :UserFeed, "github_twitter_server/feeds/user_feed"

    class ParsedFeed
      def entries
        atom.entries
      end

      def atom
        @atom ||= Atom.parse(atom_response.body)
      end

      def atom_response
        raise NotImplementedError
      end
    end

    class AtomEntry
      include SAXMachine
      element :id, :as => :guid
      element :content
      element :updated
      element :author, :as => :author_name

      def author
        @author ||= author_name.strip
      end

      def status_id
        @status_id ||= guid.to_s.split('/').last
      end

      def updated_at
        @updated_at ||= Time.parse(updated)
      end
    end

    class Atom
      include SAXMachine
      elements :entry, :as => :entries, :class => AtomEntry
    end
  end
end