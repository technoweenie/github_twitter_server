require 'sinatra'
require 'twitter_server'
require 'base64'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'github_twitter_server'

before do
  if Friendly.db.nil?
    Friendly.configure :adapter  => "sqlite", :database => ":memory:"
    GithubTwitterServer::Cacher::Feed.create_tables!
  end
end

get '/' do
  'hello world'
end

twitter_help

twitter_basic_auth do |user, pass|
  {:user => user.gsub(/^gh_/, ''), :token => pass}
end

# aka: 'wtf is tweetie sending me?'
#
#require 'pp'
#get '/statuses/home_timeline.xml' do
#  pp params
#  pp env
#end

twitter_statuses_home_timeline do |params|
  params[:auth] ||= {}
  return [] if params[:auth][:user].to_s.size.zero?

  if params[:auth][:token].to_s.size < 32
    cacher.fetch_user_feed(params[:auth][:user])
  else
    cacher.fetch_news_feed(params[:auth][:user], params[:auth][:token])
  end
end

twitter_statuses_user_timeline do |params|
  []
end

twitter_users_show do |params|
  {}
end

twitter_account_verify_credentials do |params|
  {:screen_name => params[:auth][:user]}
end

def cacher
  GithubTwitterServer::Cacher.new
end