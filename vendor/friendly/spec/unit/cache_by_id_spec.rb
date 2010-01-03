require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Cache::ByID" do
  before do
    @cache    = stub(:set => nil)
    @klass    = stub(:name => "Product")
    @id_cache = Friendly::Cache::ByID.new(@klass, [:id], {}, @cache)
    @subject  = @id_cache
  end

  it { should be_satisfies(query(:id => "asdf")) }
  it { should be_satisfies(query(:id => ["asdf"])) }
  it { should_not be_satisfies(query(:id => ["asdf"], :name => "asdf")) }
  it { should_not be_satisfies(query(:name => "asdf")) }

  it "has a default version of 0" do
    @id_cache.version.should == 0
  end

  it "is possible to override version" do
    Friendly::Cache::ByID.new(@klass, [:id], {:version => 1}).version.should == 1
  end

  describe "when an object is created" do
    before do
      @uuid = stub(:to_guid => "xxxx-xxx-xxx-xxxx")
      @doc  = stub(:id => @uuid)
      @id_cache.create(@doc)
    end

    it "sets the cache value in the db" do
      @cache.should have_received(:set).with("Product/0/#{@uuid.to_guid}", @doc)
    end
  end

  describe "when an object is updated" do
    before do
      @uuid = stub(:to_guid => "xxxx-xxx-xxx-xxxx")
      @doc  = stub(:id => @uuid)
      @id_cache.update(@doc)
    end

    it "sets the cache value in the db" do
      @cache.should have_received(:set).with("Product/0/#{@uuid.to_guid}", @doc)
    end
  end

  describe "when an object is destroyed" do
    before do
      @cache.stubs(:delete)
      @uuid = stub(:to_guid => "xxxx-xxx-xxx-xxxx")
      @doc  = stub(:id => @uuid)
      @id_cache.destroy(@doc)
    end

    it "deletes the object from cache" do
      @cache.should have_received(:delete).with("Product/0/#{@uuid.to_guid}")
    end
  end

  describe "finding a single object in cache" do
    before do
      @uuid         = stub(:to_guid => "xxxx-xxx-xxx-xxxx")
      @doc          = stub
      @cache.stubs(:get).with("Product/0/xxxx-xxx-xxx-xxxx").returns(@doc).yields
      @block_called = true
      @returned = @id_cache.first(query(:id => @uuid)) do
        @block_called = true
      end
    end

    it "returns the document" do
      @returned.should == @doc
    end

    it "passes along the block to the memcached object" do
      @block_called.should be_true
    end
  end

  describe "finding many objects in the cache" do
    before do
      @uuid         = stub(:to_guid => "xxxx-xxx-xxx-xxxx")
      @doc          = stub
      @key          = "Product/0/xxxx-xxx-xxx-xxxx"
      @cache.stubs(:multiget).with([@key, @key]).
        returns({@uuid.to_guid => @doc}).yields(@uuid.to_guid)
      @block_called = []
      @returned = @id_cache.all(query(:id => [@uuid, @uuid])) do |id|
        @block_called << id
      end
    end

    it "returns the values from the hash" do
      @returned.should == [@doc]
    end

    it "passes the block along to the cache" do
      @block_called.should == [@uuid.to_guid]
    end
  end
end
