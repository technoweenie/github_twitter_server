require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

[
  [:fetch_user_feed, :technoweenie, nil,   'technoweenie.atom'],
  [:fetch_news_feed, :technoweenie, 'abc', 'technoweenie.private.atom?token=abc']
].each do |(method, user, pass, url)|
  Class.new(FeedTestCase) do
    define_method :setup do # we want method/user/pass/url to be in the block scope
      data = feed_data(:user_feed)
      conn = Faraday::Connection.new do |b|
        b.adapter :test do |stub|
          stub.get(url) { [200, {}, data] }
        end
      end
      @cacher = GithubTwitterServer::Cacher.new
      @cacher.connection = conn
      # @cacher.fetch_user_feed(:technoweenie)
      # @cacher.fetch_news_feed(:technoweenie, 'abc)
      @items = @cacher.send(*[method, user, pass].compact)
    end

    def test_fetches_all_feed_items
      assert_equal 8, @items.size
    end

    def test_sets_status_id
      assert_equal '113924968', @items[0][:id]
      assert_equal '113908814', @items[1][:id]
      assert_equal '113907363', @items[2][:id]
      assert_equal '113902146', @items[3][:id]
      assert_equal '114814260', @items[4][:id]
      assert_equal '114807560', @items[5][:id]
      assert_equal '114806136', @items[6][:id]
      assert_equal '119438417', @items[7][:id]
    end

    def test_sets_screen_name
      assert_equal 'technoweenie', @items[0][:user][:screen_name]
      assert_equal 'technoweenie', @items[1][:user][:screen_name]
      assert_equal 'technoweenie', @items[2][:user][:screen_name]
      assert_equal 'technoweenie', @items[3][:user][:screen_name]
      assert_equal 'traviscline',  @items[4][:user][:screen_name]
      assert_equal 'mxcl',         @items[5][:user][:screen_name]
      assert_equal 'qrush',        @items[6][:user][:screen_name]
      assert_equal 'akitaonrails', @items[7][:user][:screen_name]
    end

    def test_sets_avatar
      assert_equal 'http://www.gravatar.com/avatar/abc', @items[0][:user][:profile_image_url]
    end

    def test_sets_text
      assert_equal '@technoweenie/faraday @c_a18f575 this mess is gonna get raw, like sushi', 
        @items[0][:text]
      assert_equal 'New branch is at technoweenie/github_twitter_server/tree/master', 
        @items[1][:text]
      assert_equal 'New repository is at technoweenie/github_twitter_server', 
        @items[2][:text]
      assert_equal "@technoweenie/faraday 2 commits: a18f5754 add faraday gemspec\n@bob a18f5754 add faraday gemspec", 
        @items[3][:text]
      assert_equal '@mxcl/homebrew opened #240 Updated Fourma: sip', 
        @items[4][:text]
      assert_equal '&quot;Git Guidelines&quot; is at mxcl/homebrew/wikis/git-guidelines', 
        @items[5][:text]
      assert_equal 'Deleted branch was at qrush/gemcutter/tree/add_gravatars', 
        @items[6][:text]
      assert_equal 'Started watching @technoweenie/mephisto', 
        @items[7][:text]
    end
  end
end