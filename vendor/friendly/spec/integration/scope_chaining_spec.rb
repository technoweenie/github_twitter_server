require File.expand_path("../../spec_helper", __FILE__)
require "active_support/core_ext"

describe "Chaining scopes together" do
  describe "then calling #all" do
    before do
      User.all(:name => "Quagmire").each { |q| q.destroy }
      @users = (0...10).map do |i|
        User.create :name       => "Quagmire",
                    :created_at => i.hours.ago
      end
    end

    it "queries using a combination of both scopes" do
      User.named_quagmire.recent.all.should == @users.slice(0, 3)
    end

    it "gives scopes on the right priority" do
      User.named_joe.named_quagmire.first.name.should == "Quagmire"
    end
  end
end
