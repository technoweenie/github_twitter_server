require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::StorageFactory" do
  before do
    @doc_table       = stub
    @doc_table_klass = stub(:new => @doc_table)
    @index           = stub
    @index_klass     = stub(:new => @index)
    @cache_by_id     = stub
    @cache_klass     = stub(:cache_for => @cache_by_id)
    @factory         = Friendly::StorageFactory.new(@doc_table_klass, @index_klass, 
                                                      @cache_klass)
  end

  describe "creating a document table" do
    before do
      @klass    = stub
      @returned = @factory.document_table(@klass)
    end

    it "returns the result of the constructor" do
      @returned.should == @doc_table
    end

    it "passes along the arguments to the constructor" do
      @doc_table_klass.should have_received(:new).with(@klass)
    end
  end

  describe "creating an index table" do
    before do
      @klass    = stub
      @returned = @factory.index(@klass)
    end

    it "returns the result of the constructor" do
      @returned.should == @index
    end

    it "passes along the arguments to the constructor" do
      @index_klass.should have_received(:new).with(@klass)
    end
  end

  describe "creating an id cache table" do
    before do
      @klass    = stub
      @returned = @factory.cache(@klass, [:id])
    end

    it "delegates to Cache.for" do
      @returned.should == @cache_by_id
    end

    it "supplies arguments to Cache" do
      @cache_klass.should have_received(:cache_for).with(@klass, [:id])
    end
  end
end
