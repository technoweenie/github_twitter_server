require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class UserFeedTest < FeedTestCase
  describe "#atom_data" do
    it "fetches atom data from user url" do
      user_atom_data = feed_data(:user_feed)
      conn = Faraday::TestConnection.new do |stub|
        stub.get("technoweenie.atom") { [200, {}, user_atom_data] }
      end

      feed = UserFeed.new conn, "technoweenie"
      assert_equal user_atom_data, feed.atom_response.body
    end
  end
end