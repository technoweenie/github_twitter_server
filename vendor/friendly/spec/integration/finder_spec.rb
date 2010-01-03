require File.expand_path("../../spec_helper", __FILE__)
require 'active_support/duration'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/time'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'

describe "Finding multiple objects by id" do
  before do
    @user_one = User.new
    @user_two = User.new
    @user_one.save
    @user_two.save
    @users    = User.all(:id => [@user_one.id, @user_two.id])
  end

  it "finds the objects in the database" do
    @users.length.should == 2
    @users.should include(@user_one)
    @users.should include(@user_two)
  end

  describe "when no objects are found" do
    it "returns an empty array" do
      User.all(:id => [9999, 12345, 999]).should == []
    end
  end

  describe "when one object is found, but others aren't" do
    it "returns the found objects" do
      User.all(:id => [@user_one.id, 12345]).should == [@user_one]
    end
  end
end

describe "Limiting a query" do
  before do
    10.times { User.new(:name => "Stewie").save }
    @results = User.all(:name => "Stewie", :limit! => 5)
  end

  it "returns the number of results you asked for" do
    @results.length.should == 5
  end
end

describe "limiting a query with offset" do
  before do
    @objects = (0..10).map do |i| 
      User.new(:name => "Joe", :created_at => i.minutes.from_now).tap do |u|
        u.save
      end
    end
  end

  after { @objects.each { |o| o.destroy } }

  it "returns results starting from the offset to hte limit" do
    User.all(:name    => "Joe", 
             :offset! => 2, 
             :limit!  => 2,
             :order!  => :created_at.desc).should == @objects.reverse.slice(2, 2)
  end
end
