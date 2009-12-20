require 'rubygems'
require 'context'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'github_twitter_server'

GithubTwitterServer::Feed

class FeedTestCase < Test::Unit::TestCase
  include GithubTwitterServer

  FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures')

  def feed_data(fixture)
    IO.read File.join(FIXTURE_PATH, "#{fixture}.atom")
  end
end