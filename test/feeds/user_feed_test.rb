require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class UserFeedTest < FeedTestCase
  describe "atom parsing" do
    before :all do
      @conn, @data = feed_connection 'technoweenie.atom', :user_feed
      @feed = UserFeed.new @conn, "technoweenie"
    end

    it "parses #atom_data" do
      assert_kind_of Atom, @feed.atom
    end

    it "parses atom entries" do
      assert_equal 4, @feed.entries.size
    end

    it "parses feed/entry/link" do
      assert_equal 'http://github.com/technoweenie/faraday/commit/a18f5754eb01425aadf9ad27a20fd40422e8f3e2#-P0', @feed.entries[0].link
    end

    it "parses feed/entry/content for CommitCommentEvent" do
      assert_equal '@c_a18f575 this mess is gonna get raw, like sushi', @feed.entries[0].content
    end

    it "parses feed/entry/content for CreateEvent" do
      assert_equal 'New branch is at technoweenie/github_twitter_server/tree/master', @feed.entries[1].content
    end

    it "parses feed/entry/content for PushEvent" do
      commit = "@technoweenie @c_a18f5754 add faraday gemspec"
      assert_equal "#{commit}\n#{commit}", @feed.entries[3].content
    end

    it "parses event_types" do
      assert_equal 'CommitCommentEvent', @feed.entries[0].event_type
      assert_equal 'CreateEvent',        @feed.entries[1].event_type
      assert_equal 'CreateEvent',        @feed.entries[2].event_type
      assert_equal 'PushEvent',          @feed.entries[3].event_type
    end

    it "parses feed/entry/id as :guid" do
      assert_equal 'tag:github.com,2008:CommitCommentEvent/113924968', @feed.entries[0].guid
    end

    it "converts #guid to #status_id" do
      assert_equal '113924968', @feed.entries[0].status_id
    end

    it "parses feed/entry/updated" do
      assert_equal '2009-12-19T16:40:48-00:00', @feed.entries[0].updated
    end

    it "parses feed/entry/author/name" do
      assert_equal 'technoweenie', @feed.entries[0].author
    end

    it "converts #updated to time" do
      assert_equal Time.utc(2009, 12, 19, 16, 40, 48), @feed.entries[0].updated_at
    end
  end

  describe "#atom_response" do
    it "fetches atom data from user url" do
      conn, data = feed_connection 'technoweenie.atom', :user_feed

      feed = UserFeed.new conn, "technoweenie"
      assert_equal data, feed.atom_response.body
    end
  end
end