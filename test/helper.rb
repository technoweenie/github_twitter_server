require 'rubygems'
require 'test/unit'

if ENV['LEFTRIGHT']
  require 'leftright'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'
require 'github_twitter_server'
require 'github_twitter_server/api'
require 'rack/test'
require 'nokogiri'

Friendly.configure :adapter  => "sqlite", :database => ":memory:"
GithubTwitterServer::Cacher::Feed.create_tables!

class FeedTestCase < Test::Unit::TestCase
  class << self
    attr_accessor :run_setup
  end

  def setup
    if !self.class.run_setup
      Friendly.db[:github_feeds].delete
      Friendly.db[:index_github_feeds_on_path].delete
    end
    self.class.run_setup = true
  end

  def default_test
  end

  module XmlAssertions
    def assert_xml(actual = nil)
      xml = Nokogiri::XML::Builder.new
      yield xml
      expected = xml.to_xml
      actual ||= last_response.body
      assert_equal expected, actual, "EXPECTED\n#{expected}\nACTUAL\n#{actual}"
    end
  end

  include GithubTwitterServer

  FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures')

  def feed_data(fixture)
    IO.read File.join(FIXTURE_PATH, "#{fixture}.atom")
  end
end

begin
  require 'ruby-debug'
  Debugger.start
rescue LoadError
end