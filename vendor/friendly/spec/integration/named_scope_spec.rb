require File.expand_path("../../spec_helper", __FILE__)

describe "named_scope" do
  describe "calling a single named_scope" do
    before do
      User.all(:name => "Quagmire").each { |q| q.destroy }
      5.times { User.create(:name => "Quagmire") }
    end

    describe "all" do
      it "returns all objects matching the conditions" do
        User.named_quagmire.all.should == User.all(:name => "Quagmire")
      end

      it "accepts extra conditions" do
        User.create(:name => "Fred")
        found = User.named_quagmire.all(:name => "Fred")
        found.should == User.all(:name => "Fred")
      end
    end

    describe "first" do
      it "returns the first object matching the conditions" do
        User.named_quagmire.first.should == User.first(:name => "Quagmire")
      end

      it "accepts extra conditions" do
        User.create(:name => "Fred")
        found = User.named_quagmire.first(:name => "Fred")
        found.should == User.first(:name => "Fred")
      end
    end
  end
end
