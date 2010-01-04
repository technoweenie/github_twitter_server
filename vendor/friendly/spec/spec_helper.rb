$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Dir[File.expand_path(File.dirname(__FILE__)) + "/fakes/*.rb"].each do |f|
  require f
end
require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'sequel'
require 'json/pure'
gem     'jferris-mocha'
require 'mocha'
require 'memcached'
require 'friendly'

config = YAML.load(File.read(File.dirname(__FILE__) + "/config.yml"))['test']
Friendly.configure config
$db = Friendly.db
#Sequel::MySQL.default_engine = "InnoDB"

$db.drop_table :users if $db.table_exists?("users")
$db.drop_table :index_users_on_name if $db.table_exists?("index_users_on_name")
if $db.table_exists?("index_users_on_name_and_created_at")
  $db.drop_table :index_users_on_name_and_created_at
end

datastore          = Friendly::DataStore.new($db)
Friendly.datastore = datastore

$cache = Memcached.new
Friendly.cache     = Friendly::Memcached.new($cache)

class User
  include Friendly::Document

  attribute :name,       String
  attribute :age,        Integer
  attribute :happy,      Friendly::Boolean, :default => true
  attribute :sad,        Friendly::Boolean, :default => false
  attribute :friend,     Friendly::UUID

  indexes   :happy
  indexes   :friend
  indexes   :name
  indexes   :name, :created_at

  named_scope :named_joe,      :name   => "Joe"
  named_scope :named_quagmire, :name   => "Quagmire"
  named_scope :recent,         :order! => :created_at.desc,
                               :limit! => 3

  has_many    :addresses
  has_many    :addresses_override, :class_name  => "Address",
                                   :foreign_key => :user_id
end

User.create_tables!

class Address
  include Friendly::Document

  attribute :user_id, Friendly::UUID
  attribute :street,  String

  indexes   :user_id
  indexes   :street
  caches_by :id
end

Address.create_tables!

module Mocha
  module API
    def setup_mocks_for_rspec
      mocha_setup
    end
    def verify_mocks_for_rspec
      mocha_verify
    end
    def teardown_mocks_for_rspec
      mocha_teardown
    end 
  end
end

module Factory
  def row(opts = {})
    { :id => 1, :created_at => Time.new, :updated_at => Time.new }.merge(opts)
  end

  def query(conditions)
    stub(:order           => conditions.delete(:order!), 
         :limit           => conditions.delete(:limit!),
         :preserve_order? => conditions.delete(:preserve_order!),
         :conditions      => conditions,
         :offset          => conditions.delete(:offset!))
  end
end

Spec::Runner.configure do |config|
  config.mock_with Mocha::API
  config.include Factory
end
