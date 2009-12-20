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