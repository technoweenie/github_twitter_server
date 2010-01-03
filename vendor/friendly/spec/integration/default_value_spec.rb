require File.expand_path("../../spec_helper", __FILE__)

describe "An attribute with a default value" do
  before do
    @user = User.new
  end

  it "has the value by default" do
    @user.happy.should be_true
  end

  it "has a default vaue even when it's false" do
    @user.sad.should be_false
  end
end
