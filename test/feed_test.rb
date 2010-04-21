require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class FeedTest < FeedTestCase
  def setup
    super
    data = feed_data(:user_feed)
    conn = Faraday::Connection.new do |b|
      b.adapter :test do |stub|
        stub.get('technoweenie.atom') { [200, {}, data] }
      end
    end
    @feed = Feed.new conn.get("technoweenie.atom").body
  end

  def test_parses_atom_data
    assert_kind_of Feed::Atom, @feed.atom
  end

  def test_parses_atom_entries
    assert_equal 8, @feed.entries.size
  end

  def test_parses_feed_entry_link
    assert_equal 'http://github.com/technoweenie/faraday/commit/a18f5754eb01425aadf9ad27a20fd40422e8f3e2#-P0', @feed.entries[0].link
  end

  def test_parses_feed_entry_content_for_commit_comment_event
    assert_equal '@c_a18f575 this mess is gonna get raw, like sushi', @feed.entries[0].content
  end

  def test_parses_feed_entry_content_for_create_event
    assert_equal 'New branch is at technoweenie/github_twitter_server/tree/master', @feed.entries[1].content
  end

  def test_parses_feed_entry_content_for_push_event
    commit = "a18f5754 add faraday gemspec"
    assert_equal "2 commits: #{commit}\n@bob #{commit}", @feed.entries[3].content
  end

  def test_parses_feed_entry_content_for_issues_event
    assert_equal 'opened #240 Updated Fourma: sip', @feed.entries[4].content
  end

  def test_parses_feed_entry_content_for_wiki_event
    assert_equal '&quot;Git Guidelines&quot; is at mxcl/homebrew/wikis/git-guidelines', @feed.entries[5].content
  end

  def test_parses_feed_entry_content_for_delete_event
    assert_equal 'Deleted branch was at qrush/gemcutter/tree/add_gravatars', @feed.entries[6].content
  end

  def test_combines_status_text_for_commit_comment_event
    assert_equal '@technoweenie/faraday @c_a18f575 this mess is gonna get raw, like sushi', @feed.entries[0].status_text
  end

  def test_combines_status_text_for_create_event
    assert_equal 'New branch is at technoweenie/github_twitter_server/tree/master', @feed.entries[1].status_text
  end

  def test_combines_status_text_for_push_event
    commit = "a18f5754 add faraday gemspec"
    assert_equal "@technoweenie/faraday 2 commits: #{commit}\n@bob #{commit}", @feed.entries[3].status_text
  end

  def test_combines_status_text_for_issues_event
    assert_equal '@mxcl/homebrew opened #240 Updated Fourma: sip', @feed.entries[4].status_text
  end

  def test_combines_status_text_for_wiki_event
    assert_equal '&quot;Git Guidelines&quot; is at mxcl/homebrew/wikis/git-guidelines', @feed.entries[5].status_text
  end

  def test_combines_status_text_for_delete_Event
    assert_equal 'Deleted branch was at qrush/gemcutter/tree/add_gravatars', @feed.entries[6].status_text
  end

  def test_combines_status_text_for_watch_event
    assert_equal 'Started watching @technoweenie/mephisto', @feed.entries[7].status_text
  end

  def test_parses_feed_entry_title
    assert_equal 'technoweenie commented on technoweenie/faraday', @feed.entries[0].title
  end

  def test_parses_project_name_from_feed_entry_title_for_commit_comment_event
    assert_equal 'technoweenie/faraday', @feed.entries[0].project
  end

  def test_parses_project_name_from_feed_entry_title_for_create_event
    assert_nil @feed.entries[1].project
  end

  def test_parses_project_name_from_feed_entry_title_for_push_event
    assert_equal 'technoweenie/faraday', @feed.entries[3].project
  end

  def test_parses_project_name_from_feed_entry_title_for_issues_event
    assert_equal 'mxcl/homebrew', @feed.entries[4].project
  end

  def test_parses_project_name_from_feed_entry_title_for_wiki_event
    assert_nil @feed.entries[5].project
  end

  def test_parses_project_name_from_feed_entry_title_for_delete_event
    assert_nil @feed.entries[6].project
  end

  def test_parses_event_types
    assert_equal 'CommitCommentEvent', @feed.entries[0].event_type
    assert_equal 'CreateEvent',        @feed.entries[1].event_type
    assert_equal 'CreateEvent',        @feed.entries[2].event_type
    assert_equal 'PushEvent',          @feed.entries[3].event_type
    assert_equal 'IssuesEvent',        @feed.entries[4].event_type
    assert_equal 'WikiEvent',          @feed.entries[5].event_type
    assert_equal 'DeleteEvent',        @feed.entries[6].event_type
  end

  def test_parses_feed_entry_id_as_guid
    assert_equal 'tag:github.com,2008:CommitCommentEvent/113924968', @feed.entries[0].guid
  end

  def test_converts_guid_to_status_id
    assert_equal '113924968', @feed.entries[0].status_id
  end

  def test_parses_feed_entry_updated
    assert_equal '2009-12-19T16:40:48-00:00', @feed.entries[0].updated
  end

  def test_parses_feed_entry_author_name
    assert_equal 'technoweenie', @feed.entries[0].author
  end

  def test_parses_feed_entry_avatar
    assert_equal 'http://www.gravatar.com/avatar/abc', @feed.entries[0].avatar
  end

  def test_converts_updated_at_to_time
    assert_equal Time.utc(2009, 12, 19, 16, 40, 48), @feed.entries[0].updated_at
  end

  def test_fetches_atom_data_from_user_url
    data = feed_data(:user_feed)
    conn = Faraday::Connection.new do |b|
      b.adapter :test do |stub|
        stub.get('technoweenie.atom') { [200, {}, data] }
      end
    end

    feed = Feed.new conn.get("technoweenie.atom").body
    assert_equal data, feed.response
  end
end