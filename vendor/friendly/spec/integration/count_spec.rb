require File.expand_path("../../spec_helper", __FILE__)

describe "Counting the objects matching a query" do
  before do
    User.all(:name => "Evil Monkey").each { |u| u.destroy }
    5.times { User.create :name => "Evil Monkey" }
  end

  it "does a count in the index to find out what matches" do
    User.count(:name => "Evil Monkey").should == 5
  end
end
