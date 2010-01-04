require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class FeedTest < FeedTestCase
  describe "parsing User Feed" do
    before :all do
      data = feed_data(:user_feed)
      conn = Alice::Connection.new do
        adapter :test do |stub|
          stub.get('technoweenie.atom') { [200, {}, data] }
        end
      end
      @feed = Feed.new conn.get("technoweenie.atom").body
    end

    it "parses #atom_data" do
      assert_kind_of Feed::Atom, @feed.atom
    end

    it "parses atom entries" do
      assert_equal 8, @feed.entries.size
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
      commit = "a18f5754 add faraday gemspec"
      assert_equal "2 commits: #{commit}\n@bob #{commit}", @feed.entries[3].content
    end

    it "parses feed/entry/content for IssuesEvent" do
      assert_equal 'opened #240 Updated Fourma: sip', @feed.entries[4].content
    end

    it "parses feed/entry/content for WikiEvent" do
      assert_equal '&quot;Git Guidelines&quot; is at mxcl/homebrew/wikis/git-guidelines', @feed.entries[5].content
    end

    it "parses feed/entry/content for DeleteEvent" do
      assert_equal 'Deleted branch was at qrush/gemcutter/tree/add_gravatars', @feed.entries[6].content
    end

    it "combines status text for CommitCommentEvent" do
      assert_equal '@technoweenie/faraday @c_a18f575 this mess is gonna get raw, like sushi', @feed.entries[0].status_text
    end

    it "combines status_text for CreateEvent" do
      assert_equal 'New branch is at technoweenie/github_twitter_server/tree/master', @feed.entries[1].status_text
    end

    it "combines status_text for PushEvent" do
      commit = "a18f5754 add faraday gemspec"
      assert_equal "@technoweenie/faraday 2 commits: #{commit}\n@bob #{commit}", @feed.entries[3].status_text
    end

    it "combines status_text for IssuesEvent" do
      assert_equal '@mxcl/homebrew opened #240 Updated Fourma: sip', @feed.entries[4].status_text
    end

    it "combines status_text for WikiEvent" do
      assert_equal '&quot;Git Guidelines&quot; is at mxcl/homebrew/wikis/git-guidelines', @feed.entries[5].status_text
    end

    it "combines status_text for DeleteEvent" do
      assert_equal 'Deleted branch was at qrush/gemcutter/tree/add_gravatars', @feed.entries[6].status_text
    end

    it "combines status_text for WatchEvent" do
      assert_equal 'Started watching @technoweenie/mephisto', @feed.entries[7].status_text
    end

    it "parses feed/entry/title" do
      assert_equal 'technoweenie commented on technoweenie/faraday', @feed.entries[0].title
    end

    it "parses project name from feed/entry/title for CommitCommentEvent" do
      assert_equal 'technoweenie/faraday', @feed.entries[0].project
    end

    it "parses project name from feed/entry/title for CreateEvent" do
      assert_nil @feed.entries[1].project
    end

    it "parses project name from feed/entry/title for PushEvent" do
      assert_equal 'technoweenie/faraday', @feed.entries[3].project
    end

    it "parses project name from feed/entry/title for IssuesEvent" do
      assert_equal 'mxcl/homebrew', @feed.entries[4].project
    end

    it "parses project name from feed/entry/title for WikiEvent" do
      assert_nil @feed.entries[5].project
    end

    it "parses project name from feed/entry/title for DeleteEvent" do
      assert_nil @feed.entries[6].project
    end

    it "parses event_types" do
      assert_equal 'CommitCommentEvent', @feed.entries[0].event_type
      assert_equal 'CreateEvent',        @feed.entries[1].event_type
      assert_equal 'CreateEvent',        @feed.entries[2].event_type
      assert_equal 'PushEvent',          @feed.entries[3].event_type
      assert_equal 'IssuesEvent',        @feed.entries[4].event_type
      assert_equal 'WikiEvent',          @feed.entries[5].event_type
      assert_equal 'DeleteEvent',        @feed.entries[6].event_type
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
      data = feed_data(:user_feed)
      conn = Alice::Connection.new do
        adapter :test do |stub|
          stub.get('technoweenie.atom') { [200, {}, data] }
        end
      end

      feed = Feed.new conn.get("technoweenie.atom").body
      assert_equal data, feed.response
    end
  end
end