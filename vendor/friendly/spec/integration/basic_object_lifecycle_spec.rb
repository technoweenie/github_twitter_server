require File.expand_path("../../spec_helper", __FILE__)

describe "Creating and retrieving an object" do
  before do
    @user       = User.new :name => "Stewie Griffin",
                           :age  => 3
    @user.save
    @found_user = User.find(@user.id)
  end

  it "finds the user in the database" do
    @found_user.name.should == @user.name
    @found_user.age.should  == @user.age
    @found_user.id.should   == @user.id
  end

  it "locates an object that is == to the created object" do
    @found_user.should == @user
  end

  it "sets the created_at timestamp for the record" do
    @user.created_at.should_not be_nil
    @user.created_at.should be_instance_of(Time)
  end

  it "sets the created_at on the way out of the database" do
    @found_user.created_at.should_not be_nil
    @found_user.created_at.to_i.should == @user.created_at.to_i
  end

  it "sets the updated_at on the way out of the database" do
    @found_user.updated_at.should_not be_nil
    @found_user.updated_at.to_i.should == @user.updated_at.to_i
  end

  it "sets the updated_at" do
    @user.updated_at.to_i.should == @user.created_at.to_i
  end

  it "doesn't serialize id, created_at, or updated_at in the attributes column" do
    result = $db.from("users").first(:id => @user.id)
    attrs  = JSON.parse(result[:attributes])
    attrs.keys.should_not include("id")
    attrs.keys.should_not include("created_at")
    attrs.keys.should_not include("updated_at")
  end

  it "has an id of type Friendly::UUID" do
    @user.id.should be_kind_of(Friendly::UUID)
  end
end

describe "Updating an object" do
  before do
    @user = User.new :name => "Stewie Griffin",
                     :age  => 3
    @user.save
    @created_id = @user.id
    @created_at = @user.created_at

    sleep(0.1)
    @user.name = "Brian Griffin"
    @user.age  = 8
    @user.save

    @found_user = User.find(@created_id)
  end

  it "sets the updated_at column" do
    @user.updated_at.should_not be_nil
    @user.updated_at.should_not == @user.created_at
    @user.updated_at.should > @user.created_at
  end

  it "doesn't change the created_at" do
    @user.created_at.should == @created_at
  end

  it "doesn't change the id" do
    @user.id.should == @created_id
  end

  it "saves the new attrs to the db" do
    @found_user.name.should == "Brian Griffin"
    @found_user.age.should  == 8
  end
end

describe "destroying a document" do
  before do
    @user = User.new :name => "Stewie Griffin"
    @user.save
    @user.destroy
  end

  it "removes it from the database" do
    User.first(:id => @user.id).should be_nil
  end
end

describe "Finding an object by id" do
  it "raises Friendly::RecordNotFound if it doesn't exist" do
    lambda { User.find(12345) }.should raise_error(Friendly::RecordNotFound)
  end
end

describe "An object that has a foreign key" do
  it "is saveable in the database" do
    lambda {
        Address.create :user_id => Friendly::UUID.new
    }.should_not raise_error
  end
end

