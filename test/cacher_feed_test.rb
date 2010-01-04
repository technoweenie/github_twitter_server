require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class CacherFeedTest < FeedTestCase
  before :all do
    @data    = feed_data(:simple)
  end

  describe "parsing User Feed" do
    before :all do
      @expired = Cacher::Feed.create :path => 'zenhob.atom',       :atom => 'expired', :created_at => (Time.now - Cacher::Feed.cache_threshold * 2)
      @cached  = Cacher::Feed.create :path => 'technoweenie.atom', :atom => @data,     :created_at => (Time.now - Cacher::Feed.cache_threshold / 2)
    end

    before do
      data  = @data
      @conn = Alice::Connection.new do
        adapter :test do |stub|
          stub.get('zenhob.atom') { [200, {}, data] }
          stub.get('towski.atom') { [200, {}, data] }
        end
      end
      @cacher = Cacher.new
      @cacher.connection = @conn
    end

    it "fetches expired feed and updates atom/timestamp" do
      items = @cacher.fetch_user_feed(:zenhob)
      assert_equal 1, items.size
      assert_equal @data, Cacher::Feed.first(:path => 'zenhob.atom').atom
      
    end

    it "fetches new feed and creates cached record" do
      assert_nil Cacher::Feed.first(:path => 'towski.atom')
      items = @cacher.fetch_user_feed(:towski)
      assert_equal 1, items.size
      assert_not_nil Cacher::Feed.first(:path => 'towski.atom')
    end

    it "retrieves cached feed" do
      items = @cacher.fetch_user_feed(:technoweenie)
      assert_equal 1, items.size
    end
  end

  describe "parsing News Feed" do
    before :all do
      @expired = Cacher::Feed.create :path => 'zenhob.private.atom',       :atom => 'expired', :created_at => (Time.now - Cacher::Feed.cache_threshold * 2)
      @cached  = Cacher::Feed.create :path => 'technoweenie.private.atom', :atom => @data,     :created_at => (Time.now - Cacher::Feed.cache_threshold / 2)
    end

    before do
      data  = @data
      @conn = Alice::Connection.new do
        adapter :test do |stub|
          stub.get('zenhob.private.atom') { [200, {}, data] }
          stub.get('towski.private.atom') { [200, {}, data] }
        end
      end
      @cacher = Cacher.new
      @cacher.connection = @conn
    end

    it "fetches expired feed and updates atom/timestamp" do
      items = @cacher.fetch_news_feed(:zenhob, 'abc')
      assert_equal 1, items.size
      assert_equal @data, Cacher::Feed.first(:path => 'zenhob.private.atom').atom
      
    end

    it "fetches new feed and creates cached record" do
      assert_nil Cacher::Feed.first(:path => 'towski.atom')
      items = @cacher.fetch_news_feed(:towski, 'abc')
      assert_equal 1, items.size
      assert_not_nil Cacher::Feed.first(:path => 'towski.private.atom')
    end

    it "retrieves cached feed" do
      items = @cacher.fetch_news_feed(:technoweenie, 'abc')
      assert_equal 1, items.size
    end
  end
end