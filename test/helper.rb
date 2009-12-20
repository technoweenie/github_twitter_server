require 'rubygems'
require 'context'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'github_twitter_server'

class FeedTestCase < Test::Unit::TestCase
  include GithubTwitterServer::Feeds

  FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures')

  def feed_connection(path, fixture)
    data = feed_data(fixture)
    conn = Faraday::TestConnection.new do |stub|
      stub.get(path) { [200, {}, data] }
    end
    [conn, data]
  end

  def feed_data(fixture)
    IO.read File.join(FIXTURE_PATH, "#{fixture}.atom")
  end
end