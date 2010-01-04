require File.expand_path("../../spec_helper", __FILE__)
require 'active_support/core_ext'

describe "Paginating" do
  before do
    User.all(:name => "Fred").each { |u| u.destroy }
    @users = (0...15).map do |i|
      User.create(:name       => "Fred", 
                  :created_at => i.hours.ago)
    end
  end

  describe "fetching the nil page" do
    before do
      @found = User.paginate(:name      => "Fred", 
                             :order!    => :created_at.desc,
                             :page!     => nil,
                             :per_page! => 5)
    end

    it "returns the first :per_page results" do
      @found.should == @users.slice(0,5)
    end

    it "returns an instance of WillPaginate::Collection" do
      @found.should be_instance_of(WillPaginate::Collection)
    end
  end

  describe "fetching a page by number" do
    before do
      @found = User.paginate(:name      => "Fred", 
                             :order!    => :created_at.desc,
                             :page!     => 2,
                             :per_page! => 5)
    end

    it "returns the :per_page results starting at offset :per_page * page" do
      @found.should == @users.slice(5,5)
    end

    it "returns an instance of WillPaginate::Collection" do
      @found.should be_instance_of(WillPaginate::Collection)
    end
  end

  describe "when :page is a string" do
    before do
      @found = User.paginate(:name      => "Fred", 
                             :order!    => :created_at.desc,
                             :page!     => "2",
                             :per_page! => 5)
    end

    it "returns the :per_page results starting at offset :per_page * page" do
      @found.should == @users.slice(5,5)
    end

    it "returns an instance of WillPaginate::Collection" do
      @found.should be_instance_of(WillPaginate::Collection)
    end
  end
end
