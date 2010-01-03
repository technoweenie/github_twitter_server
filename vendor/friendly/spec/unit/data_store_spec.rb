require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::DataStore" do
  before do
    @users     = DatasetFake.new(:insert => 42)
    @db        = DatabaseFake.new("users" => @users)
    @datastore = Friendly::DataStore.new(@db)
    @klass     = stub(:table_name => "users")
  end

  describe "inserting data" do
    before do
      @return = @datastore.insert(@klass, :name => "Stewie")
    end

    it "inserts it in to the table in the datastore" do
      @users.inserts.length.should == 1
      @users.inserts.should include(:name => "Stewie")
    end

    it "returns the id from the dataset" do
      @return.should == 42
    end
  end

  describe "retrieving all based on a query" do
    before do
      @users.where = {{:name => "Stewie"} => stub(:map => [{:id => 1}])}
      @return = @datastore.all(@klass, query(:name => "Stewie"))
    end

    it "gets the data from the dataset for the klass and makes it an arary" do
      @return.should == [{:id => 1}]
    end
  end

  describe "retrieving all with a limit" do
    before do
      @filtered    = stub
      @filtered.stubs(:limit).with(10, nil).returns(stub(:map => [{:id => 1}]))
      @users.where = {{:name => "Stewie"} => @filtered}
      @query       = query(:name => "Stewie", :limit! => 10)
      @return      = @datastore.all(@klass, @query)
    end

    it "limits the filtered dataset and returns the results" do
      @return.should == [{:id => 1}]
    end
  end

  describe "retrieving all with a offset" do
    before do
      @filtered    = stub
      @filtered.stubs(:limit).with(nil, 10).returns(stub(:map => [{:id => 1}]))
      @users.where = {{:name => "Stewie"} => @filtered}
      @query       = query(:name => "Stewie", :offset! => 10)
      @return      = @datastore.all(@klass, @query)
    end

    it "offsets the filtered dataset and returns the results" do
      @return.should == [{:id => 1}]
    end
  end

  describe "retrieving all with order" do
    before do
      @filtered    = stub
      @filtered.stubs(:order).with(:created_at).returns(stub(:map => [{:id => 1}]))
      @users.where = {{:name => "Stewie"} => @filtered}
      @query       = query(:name => "Stewie", :order! => :created_at)
      @return      = @datastore.all(@klass, @query)
    end

    it "orders the filtered dataset and returns the results" do
      @return.should == [{:id => 1}]
    end
  end

  describe "retrieving first with conditions" do
    before do
      @users.first = {{:id => 1} => {:id => 1}}
      @return = @datastore.first(@klass, query(:id => 1))
    end

    it "gets the first object matching the conditions from the dataset" do
      @return.should == {:id => 1}
    end
  end

  describe "updating data" do
    before do
      @filtered    = DatasetFake.new(:update => true)
      @users.where = {{:id => 1} => @filtered}
      @return = @datastore.update(@klass, 1, :name => "Peter")
    end

    it "filter the dataset by id and update the filtered row" do
      @filtered.updates.length.should == 1
      @filtered.updates.should include(:name => "Peter")
    end
  end

  describe "deleting data" do
    before do
      @filtered = stub
      @filtered.stubs(:delete)
      @users.where = {{:id => 1} => @filtered}
      @datastore.delete(@klass, 1)
    end

    it "filters the dataset by id and deletes" do
      @filtered.should have_received(:delete)
    end
  end

  describe "when a batch transaction has been started" do
    before do
      @datastore.start_batch
      @persistable = stub(:table_name => "some_table")
      @datastore.insert(@persistable, {:some => "attrs"})
    end

    after { Thread.current[:friendly_batch] = nil }

    it "adds the attributes to the batch for that table" do
      inserts = Thread.current[:friendly_batch]["some_table"]
      inserts.length.should == 1
      inserts.should include(:some => "attrs")
    end
  end

  describe "starting a batch" do
    before do
      @datastore.start_batch
    end

    after { Thread.current[:friendly_batch] = nil }

    it "sets Thread.current[:friendly_batch] to empty hash" do
      Thread.current[:friendly_batch].should == {}
    end
  end

  describe "resetting a batch transaction" do
    before do
      @db.stubs(:from)
      Thread.current[:friendly_batch] = {"users" => [{:a => "b"}]}
      @datastore.reset_batch
    end
    after { Thread.current[:friendly_batch] = nil }

    it "sets Thread.current[:friendly_batch] to nil without inserting" do
      Thread.current[:friendly_batch].should be_nil
      @db.should have_received(:from).never
    end
  end

  describe "flushing a batch" do
    before do
      @records = [{:name => "Stewie"}, {:name => "Brian"}]
      Thread.current[:friendly_batch] = {"users" => @records}
      @users.stubs(:multi_insert)
      @datastore.flush_batch
    end
    after { Thread.current[:friendly_batch] = nil }

    it "performs the multi_insert on each table" do
      @users.should have_received(:multi_insert).
          with(@records, :commit_every => 1000)
    end

    it "resets the batch" do
      Thread.current[:friendly_batch].should be_nil
    end
  end

  describe "counting" do
    before do
      @filtered = stub(:count => 10)
      @users.stubs(:where).with(:name => "James").returns(@filtered)
    end

    it "fitlers and counts in the db" do
      @datastore.count(@klass, query(:name => "James")).should == 10
    end
  end
end

