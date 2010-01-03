require File.expand_path("../../spec_helper", __FILE__)

describe "Batch inserting several documents" do
  it "inserts them when the block returns" do
    Friendly.batch do
      user = User.new(:name => "Lois")
      user.save
      User.all(:name => "Lois").should be_empty
    end

    User.all(:name => "Lois").should_not be_empty
  end

  it "doesn't insert anything if an error is raised" do
    begin
      Friendly.batch do
        user = User.new(:name => "Meg")
        user.save
        raise "AHHHH!"
      end
    rescue RuntimeError => e
      @bubbled_up = true
    end

    @bubbled_up.should be_true

    User.all(:name => "Meg").should be_empty
  end
end
