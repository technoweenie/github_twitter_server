require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class CacherUserFeedTest < FeedTestCase
  def setup
    super
    data  = @data = feed_data(:simple)
    @conn = Faraday::Connection.new do |b|
      b.adapter :test do |stub|
        stub.get('zenhob.atom') { [200, {}, data] }
        stub.get('towski.atom') { [200, {}, data] }
      end
    end
    @cacher = Cacher.new
    @cacher.connection = @conn
  end

  def test_fetches_expired_feed_and_updates_atom_timestamp
    Cacher::Feed.create :path => 'zenhob.atom', :atom => 'expired', :created_at => (Time.now - Cacher::Feed.cache_threshold * 2)
    items = @cacher.fetch_user_feed(:zenhob)
    assert_equal 1, items.size
    assert_equal @data, Cacher::Feed.first(:path => 'zenhob.atom').atom
    
  end

  def test_fetches_new_feed_and_creates_cached_record
    assert_nil Cacher::Feed.first(:path => 'towski.atom')
    items = @cacher.fetch_user_feed(:towski)
    assert_equal 1, items.size
    assert_not_nil Cacher::Feed.first(:path => 'towski.atom')
  end

  def test_retrieves_cached_feed
    Cacher::Feed.create :path => 'technoweenie.atom', :atom => @data, :created_at => (Time.now - Cacher::Feed.cache_threshold / 2)
    items = @cacher.fetch_user_feed(:technoweenie)
    assert_equal 1, items.size
  end
end

class CacherNewsFeedTest < FeedTestCase
  def setup
    super
    data  = @data = feed_data(:simple)
    @conn = Faraday::Connection.new do |b|
      b.adapter :test do |stub|
        stub.get('zenhob.private.atom?token=abc') { [200, {}, data] }
        stub.get('towski.private.atom?token=abc') { [200, {}, data] }
      end
    end
    @cacher = Cacher.new
    @cacher.connection = @conn
  end

  def test_fetches_expired_feed_and_updates_atom_timestamp
    Cacher::Feed.create :path => 'zenhob.private.atom', :atom => 'expired', :created_at => (Time.now - Cacher::Feed.cache_threshold * 2)
    items = @cacher.fetch_news_feed(:zenhob, 'abc')
    assert_equal 1, items.size
    assert_equal @data, Cacher::Feed.first(:path => 'zenhob.private.atom').atom
    
  end

  def test_fetches_new_feed_and_creates_cached_record
    assert_nil Cacher::Feed.first(:path => 'towski.atom')
    items = @cacher.fetch_news_feed(:towski, 'abc')
    assert_equal 1, items.size
    assert_not_nil Cacher::Feed.first(:path => 'towski.private.atom')
  end

  def test_retrieves_cached_feed
    Cacher::Feed.create :path => 'technoweenie.private.atom', :atom => @data, :created_at => (Time.now - Cacher::Feed.cache_threshold / 2)
    items = @cacher.fetch_news_feed(:technoweenie, 'abc')
    assert_equal 1, items.size
  end
end