require 'rubygems'
require 'rake'

namespace :ghtw do
  task :init do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'github_twitter_server'
    Friendly.configure ENV['DATABASE_URL']
  end

  namespace :db do
    task :create => 'ghtw:init' do
      GithubTwitterServer::Cacher::Feed.create_tables!
    end
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "github_twitter_server"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "technoweenie@gmail.com"
    gem.homepage = "http://github.com/technoweenie/github-twitter-server"
    gem.authors = ["rick"]
    gem.add_dependency "faraday", "~> 0.1.0"
    gem.add_dependency "sax-machine", ">= 0"
    gem.add_dependency "twitter_server", ">= 0"
    gem.add_dependency "friendly", ">= 0"
    gem.add_development_dependency "context", ">= 0"
    gem.add_development_dependency "nokogiri", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "github_twitter_server #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
