require File.expand_path("../../spec_helper", __FILE__)

describe "Has many associations" do
  before do
    @user      = User.create :name => "Fred"
    @addresses = (0..2).map { Address.create :user_id => @user.id }
  end

  it "returns the objects whose foreign keys match the object's id" do
    found = @user.addresses.all.sort { |a, b| a.id <=> b.id }
    found.should == @addresses.sort { |a, b| a.id <=> b.id }
  end

  it "accepts class_name and foreign_key overrides" do
    found = @user.addresses_override.all.sort { |a, b| a.id <=> b.id }
    found.should == @addresses.sort { |a, b| a.id <=> b.id }
  end
end
