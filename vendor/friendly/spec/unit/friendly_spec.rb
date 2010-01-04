require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly" do
  describe "configuring friendly" do
    before do
      @datastore = stub
      Friendly::DataStore.stubs(:new).returns(@datastore)
      @db = stub(:meta_def => nil)
      Sequel.stubs(:connect).returns(@db)
      Friendly.configure(:host => "localhost")
    end

    it "creates a db object by delegating to Sequel" do
      Sequel.should have_received(:connect).with(:host => "localhost")
    end

    it "creates a datastore object with the db object" do
      Friendly::DataStore.should have_received(:new).with(@db)
    end

    it "sets the datastore as the default" do
      Friendly.datastore.should == @datastore
    end
  end
end
