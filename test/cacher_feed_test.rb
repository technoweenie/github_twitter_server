require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class CacherFeedTest < FeedTestCase
  describe "parsing User Feed" do
    before :all do
      @data    = feed_data(:simple)
      @expired = Cacher::Feed.create :path => 'zenhob.atom',       :atom => 'expired', :created_at => (Time.now - Cacher::Feed.cache_threshold * 2)
      @cached  = Cacher::Feed.create :path => 'technoweenie.atom', :atom => @data,     :created_at => (Time.now - Cacher::Feed.cache_threshold / 2)
    end

    before do
      @conn = Faraday::TestConnection.new do |stub|
        stub.get('zenhob.atom') { [200, {}, @data] }
        stub.get('towski.atom') { [200, {}, @data] }
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
end