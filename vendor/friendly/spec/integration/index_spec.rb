require File.expand_path("../../spec_helper", __FILE__)
require 'active_support/duration'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/time'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'

describe "Finding one object with an index" do
  before do
    @created_user = User.new(:name => "Cleveland")
    @created_user.save
    @found_user   = User.first(:name => "Cleveland")
  end

  it "finds the object" do
    @found_user.should == @created_user
  end
end

describe "Finding one object that doesn't exist in the index" do
  it "returns nil" do
    User.first(:name => "asdf").should be_nil
  end
end

describe "Finding object on an index that doesn't exist" do
  it "raises Friendly::MissingIndex" do
    lambda {
      User.first(:age => 3) 
    }.should raise_error(Friendly::MissingIndex)
  end
end

describe "Finding ordered objects" do
  before do
    @three = User.new(:name => "Brian", :created_at => 4.hours.ago)
    @two   = User.new(:name => "Brian", :created_at => 2.hours.ago)
    @one   = User.new(:name => "Brian", :created_at => 5.minutes.ago)
    [@one, @two, @three].each { |i| i.save }
  end

  after do
    [@one, @two, @three].each { |i| i.destroy }
  end

  it "can return the objects in desc order" do
    found_users = User.all(:name => "Brian", :order! => :created_at.desc)
    found_users.should == [@one, @two, @three]
  end

  it "can return the objects in asc order" do
    found_users = User.all(:name => "Brian", :order! => :created_at.asc)
    found_users.length.should == 3
    found_users.should == [@three, @two, @one]
  end
end

