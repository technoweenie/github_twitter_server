require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::StorageProxy" do
  before do
    @klass          = stub
    @index          = stub(:create     => nil, 
                           :update     => nil, 
                           :destroy    => nil,
                           :satsifies? => nil)
    @table          = stub(:satisfies? => false, :create => nil, 
                           :update => nil,       :destroy => nil)
    @storage_factory  = stub(:index => @index)
    @storage_factory.stubs(:document_table).with(@klass).returns(@table)
    @storage        = Friendly::StorageProxy.new(@klass, @storage_factory)
  end

  it "instantiates and adds a document table by default" do
    @storage.tables.should include(@table)
  end

  describe "doing a `first`" do
    before do
      @id     = stub
      @index  = stub(:satisfies? => true, :first => @id)
      @storage.tables << @index
    end

    describe "when there's an index that matches the conditions" do
      before do
        @result = @storage.first(:name => "x")
      end

      it "delegates to the index that satisfies the conditions" do
        @index.should have_received(:first).once
        @index.should have_received(:first).with(:name => "x")
      end

      it "returns id" do
        @result.should == @id
      end
    end

    describe "when there's no index that matches" do
      before do
        @index.stubs(:satisfies?).returns(false)
      end

      it "raises MissingIndex" do
        lambda {
          @storage.first(:name => "x")
        }.should raise_error(Friendly::MissingIndex)
      end
    end
  end

  describe "doing an `all`" do
    before do
      @ids    = [stub]
      @index  = stub(:satisfies? => true, :all => @ids)
      @storage.tables << @index
    end

    describe "when there's an index that matches the conditions" do
      before do
        @query  = query(:name => "x")
        @result = @storage.all(@query)
      end

      it "delegates to the index that satisfies the conditions" do
        @index.should have_received(:all).once
        @index.should have_received(:all).with(@query)
      end

      it "returns the results" do
        @result.should == @ids
      end
    end

    describe "when there's no index that matches" do
      before do
        @index.stubs(:satisfies?).returns(false)
      end

      it "raises MissingIndex" do
        lambda {
          @storage.all(:name => "x")
        }.should raise_error(Friendly::MissingIndex)
      end
    end

    describe "when :preserve_order is true" do
      before do
        @docs  = [stub(:id => 4), stub(:id => 3), stub(:id => 2)]
        @index.stubs(:all).returns(@docs)
        @result = @storage.all(query(:id => [2,3,4], :preserve_order! => true))
      end

      it "sorts the results based on the order they're supplied in the query" do
        @result.should == @docs.reverse
      end
    end
  end

  describe "adding an index to the set" do
    before do
      @storage.add(:name, :age)
    end

    it "creates an index" do
      @storage_factory.should have_received(:index).once
      @storage_factory.should have_received(:index).with(@klass, :name, :age)
    end

    it "adds the index to the set" do
      @storage.tables.should include(@index)
    end
  end

  describe "saving data" do
    before do
      @index_two = stub(:create => nil, :update => nil, :destroy => nil)
      @storage_factory.stubs(:index).returns(@index).then.returns(@index_two)
      @cache     = stub(:create => nil, :update => nil, :destroy => nil)
      @storage_factory.stubs(:cache).returns(@cache)
      @storage.add(:name)
      @storage.add(:age)
      @storage.cache([:id])
      @doc = stub
    end

    describe "on create" do
      before do
        @storage.create(@doc)
      end

      it "delegates to all of the storage including caches" do
        @index.should have_received(:create).with(@doc)
        @index_two.should have_received(:create).with(@doc)
        @table.should have_received(:create).with(@doc)
        @cache.should have_received(:create).with(@doc)
      end
    end

    describe "on update" do
      before do
        @storage.update(@doc)
      end

      it "delegates to all of the storage including caches" do
        @index.should have_received(:update).with(@doc)
        @index_two.should have_received(:update).with(@doc)
        @table.should have_received(:update).with(@doc)
        @cache.should have_received(:update).with(@doc)
      end
    end

    describe "on destroy" do
      before do
        @storage.destroy(@doc)
      end

      it "delegates to all of the storage including caches" do
        @index.should have_received(:destroy).with(@doc)
        @index_two.should have_received(:destroy).with(@doc)
        @table.should have_received(:destroy).with(@doc)
        @cache.should have_received(:destroy).with(@doc)
      end
    end
  end

  describe "adding a cache object" do
    before do
      @cache = stub
      @storage_factory.stubs(:cache).returns(@cache)
      @storage.cache([:id])
    end

    it "gets one from the storage_proxy" do
      @storage_factory.should have_received(:cache).with(@klass, [:id], {})
    end

    it "adds it to its set of caches" do
      @storage.caches.should include(@cache)
    end
  end

  describe "finding with a matching cache" do
    before do
      @cache = stub(:satisfies? => true, :first => nil)
      @storage_factory.stubs(:cache).returns(@cache)
      @storage.cache([:id])
    end

    describe "when there's a hit" do
      before do
        @doc = stub
        @cache.stubs(:first).returns(@doc)
      end

      it "returns the result from the cache" do
        @storage.first(:id => "x").should == @doc
      end
    end
  end

  describe "counting objects" do
    before do
      @index = stub(:count => 10)
      @index.stubs(:satisfies?).with(:x => 1).returns(true)
      @storage_factory.stubs(:index).returns(@index)
      @storage.add(:a)
    end

    it "delegates to a satisfying index" do
      @storage.count(:x => 1).should == 10
    end
  end
end
