module GithubTwitterServer
  class Cacher
    class Feed
      class << self
        attr_accessor :cache_threshold
      end

      self.cache_threshold = 5 * 60

      include Friendly::Document
      attribute :path, String
      attribute :atom, String

      indexes :path

      self.table_name = :github_feeds

      def self.read(path)
        feed = first(:path => path)
        if feed && Time.now - feed.created_at < @cache_threshold
          feed.atom
        else
          atom = yield path
          if feed
            feed.atom       = atom
            feed.created_at = Time.now.utc
            feed.save
          else
            create(:path => path, :atom => atom)
          end
          atom
        end
      end
    end
  end
end