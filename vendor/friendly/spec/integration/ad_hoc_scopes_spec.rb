require File.expand_path("../../spec_helper", __FILE__)

describe "Querying with an ad-hoc scope" do
  before do
    User.all(:name => "Fred").each { |u| u.destroy }
    @users = (1..10).map { User.create(:name => "Fred") }
  end

  it "can return all the objects matching the scope" do
    User.scope(:name => "Fred").all.should == @users
  end

  it "can return the first object matching the scope" do
    User.scope(:name => "Fred").first.should == User.first(:name => "Fred")
  end

  it "can paginate over the matching objects" do
    found = User.scope(:name => "Fred").paginate(:per_page! => 5)
    found.should == User.paginate(:name => "Fred", :per_page! => 5)
  end

  it "can build an object at scope" do
    User.scope(:name => "Fred", :limit! => 5).build.name.should == "Fred"
  end

  it "supports overriding parameters when building" do
    scope = User.scope(:name => "Fred", :limit! => 5)
    scope.build(:name => "Joe").name.should == "Joe"
  end

  it "can create an object at scope" do
    user = User.scope(:name => "Joe").create
    user.should_not be_new_record
    user.name.should == "Joe"
  end

  it "supports overriding parameters when creating" do
    user = User.scope(:name => "Joe").create(:name => "Fred")
    user.should_not be_new_record
    user.name.should == "Fred"
  end
end
