require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Document" do
  before do
    @klass = Class.new { include Friendly::Document }
    @klass.attribute(:name, String)
    @storage_proxy = stub
    @klass.storage_proxy = @storage_proxy
  end

  it "delegates table_name to it's class" do
    User.new.table_name.should == User.table_name
  end

  it "always has an id attribute" do
    @klass.attributes[:id].type.should == Friendly::UUID
  end

  it "always has a created_at attribute" do
    @klass.attributes[:created_at].type.should == Time
  end

  it "always has a updated_at attribute" do
    @klass.attributes[:updated_at].type.should == Time
  end

  describe "saving a new document" do
    before do
      @user = @klass.new(:name => "whatever")
      @storage_proxy.stubs(:create)
      @user.save
    end

    it "asks the storage_proxy to create" do
      @storage_proxy.should have_received(:create).with(@user)
    end
  end

  describe "saving an existing document" do
    before do
      @user = @klass.new(:name => "whatever", :id => 42, :new_record => false)
      @storage_proxy.stubs(:update)
      @user.save
    end

    it "asks the storage_proxy to update" do
      @storage_proxy.should have_received(:update).with(@user)
    end
  end

  describe "destroying a document" do
    before do
      @user = @klass.new
      @storage_proxy.stubs(:destroy)
      @user.destroy
    end

    it "delegates to the storage proxy" do
      @storage_proxy.should have_received(:destroy).with(@user)
    end
  end

  describe "converting a document to a hash" do
    before do
      @object = @klass.new(:name => "Stewie")
    end

    it "creates a hash that contains its attributes" do
      @object.to_hash.should == {:name       => "Stewie", 
                                 :id         => @object.id, 
                                 :created_at => @object.created_at,
                                 :updated_at => @object.updated_at}
    end
  end

  describe "setting the attributes all at once" do
    before do
      @object = @klass.new
      @object.attributes = {:name => "Bond"}
    end

    it "sets the attributes using the setters" do
      @object.name.should == "Bond"
    end

    it "raises ArgumentError when there are duplicate keys of differing type" do
      lambda { 
        @object.attributes = {:name => "Bond", "name" => "Bond"}
      }.should raise_error(ArgumentError)
    end
  end

  describe "initializing a document" do
    before do
      @doc = @klass.new :name => "Bond"
    end

    it "sets the attributes using the setters" do
      @doc.name.should == "Bond"
    end
  end

  describe "table name" do
    it "by default: is the class name, converted with pluralize.underscore" do
      User.table_name.should == "users"
    end

    it "is overridable" do
      @klass.table_name = "ASDF"
      @klass.table_name.should == "ASDF"
    end
  end

  describe "new record" do
    before do
      @object = @klass.new
    end

    it "is new_record by default" do
      @object.should be_new_record
    end

    it "is not new_record when new_record is set to false" do
      @object.new_record = false
      @object.should_not be_new_record
    end
  end

  describe "object equality" do
    it "is never equal if both objects are new_records" do
      @klass.new(:name => "x").should_not == @klass.new(:name => "x")
    end

    it "is equal if both objects have the same id" do
      uuid = Friendly::UUID.new
      one  = @klass.new(:id => uuid, :new_record => false)
      one.should == @klass.new(:id => uuid, :new_record => false)
    end

    it "is equal if the objects point to the same reference" do
      obj = @klass.new
      obj.should == obj
    end

    it "is not equal if two objects are of differing types with the same id" do
      @klass.new(:id => 1).should_not == User.new(:id => 1)
    end
  end

  describe "adding an index" do
    before do
      @storage_proxy.stubs(:add)
      @klass = Class.new { include Friendly::Document }
      @klass.storage_proxy = @storage_proxy
      @klass.indexes :name
    end

    it "delegates to the storage_proxy" do
      @klass.storage_proxy.should have_received(:add).with([:name])
    end
  end

  describe "adding a cache" do
    before do
      @storage_proxy.stubs(:cache)
      @klass.caches_by(:name, :created_at)
    end

    it "delegates to the storage_proxy" do
      @storage_proxy.should have_received(:cache).with([:name, :created_at], {})
    end
  end

  describe "Document.first" do
    before do
      @doc               = stub
      @query             = stub
      @query_klass       = stub
      @klass.query_klass = @query_klass
      @query_klass.stubs(:new).with(:id => 1).returns(@query)
      @storage_proxy.stubs(:first).with(@query).returns(@doc)
    end

    it "creates a query object and delegates to the storage proxy" do
      @klass.first(:id => 1).should == @doc
    end
  end

  describe "Document.all" do
    before do
      @docs              = stub
      @query             = stub
      @query_klass       = stub
      @klass.query_klass = @query_klass
      @query_klass.stubs(:new).with(:name => "x").returns(@query)
      @storage_proxy.stubs(:all).with(@query).returns(@docs)
    end

    it "delegates to the storage proxy" do
      @klass.all(:name => "x").should == @docs
    end
  end

  describe "Document.find" do
    describe "when an object is found" do
      before do
        @doc               = stub
        @query             = stub
        @query_klass       = stub
        @klass.query_klass = @query_klass
        @query_klass.stubs(:new).with(:id => 1).returns(@query)
        @storage_proxy.stubs(:first).with(@query).returns(@doc)
      end

      it "queries the storage proxy" do
        @klass.find(1).should == @doc
      end
    end

    describe "when no object is found" do
      before do
        @storage_proxy.stubs(:first).returns(nil)
      end

      it "raises RecordNotFound" do
        lambda {
          @klass.find(1)
        }.should raise_error(Friendly::RecordNotFound)
      end
    end
  end

  describe "Document.all" do
    before do
      @query             = stub
      @query_klass       = stub
      @klass.query_klass = @query_klass
      @query_klass.stubs(:new).with(:name => "x").returns(@query)
      @storage_proxy.stubs(:count).with(@query).returns(25)
    end

    it "delegates to the storage proxy" do
      @klass.count(:name => "x").should == 25
    end
  end

  describe "Document.create" do
    before do
      @storage_proxy.stubs(:create)
      @doc = @klass.create(:name => "James")
    end

    it "initializes, then saves the document and returns it" do
      @storage_proxy.should have_received(:create).with(@doc)
      @doc.should be_kind_of(@klass)
    end
  end

  describe "Document#update_attributes" do
    before do
      @storage_proxy.stubs(:update)
      @doc = @klass.new(:name => "James", :new_record => false)
      @doc.update_attributes :name => "Steve"
    end

    it "sets the attributes" do
      @doc.name.should == "Steve"
    end

    it "saves the document" do
      @storage_proxy.should have_received(:update).with(@doc)
    end
  end

  describe "when document has been included" do
    after { Friendly::Document.documents = [] }
    it "adds the document to the collection" do
      Friendly::Document.documents.should include(@klass)
    end
  end

  describe "Document.paginate" do
    before do
      @conditions             = {:name => "Stewie", :page! => 1, :per_page! => 20}
      @query                  = stub(:page => 1, :per_page => 20)
      @docs                   = stub
      @query_klass            = stub
      @klass.query_klass      = @query_klass
      @count                  = 10
      @collection_klass       = stub
      @collection             = stub
      @klass.collection_klass = @collection_klass
      @collection.stubs(:replace).returns(@collection)
      @collection_klass.stubs(:new).with(1, 20, @count).returns(@collection)
      @query_klass.stubs(:new).returns(@query)
      @storage_proxy.stubs(:count).with(@query).returns(@count)
      @storage_proxy.stubs(:all).with(@query).returns(@docs)

      @pagination = @klass.paginate(@conditions)
    end

    it "creates an instance of the collection klass and returns it" do
      @pagination.should == @collection
    end

    it "fills the collection with objects from the datastore" do
      @collection.should have_received(:replace).with(@docs)
    end
  end

  describe "creating a named_scope" do
    before do
      @scope_proxy           = stub(:add_named => nil)
      @klass.scope_proxy     = @scope_proxy
      @klass.named_scope(:by_name, :order => :name)
    end

    it "asks the named_scope_set to add it" do
      @klass.scope_proxy.should have_received(:add_named).
                                  with(:by_name, :order => :name)
    end
  end

  describe "Document.has_named_scope?" do
    it "delegates to the scope_proxy" do
      @scope_proxy       = stub
      @scope_proxy.stubs(:has_named_scope?).with(:whatever).returns(true)
      @klass.scope_proxy = @scope_proxy
      @klass.has_named_scope?(:whatever).should be_true
    end
  end

  describe "accessing an ad-hoc scope" do
    before do
      @scope             = stub
      @scope_proxy       = stub
      @scope_proxy.stubs(:ad_hoc).with(:order! => :name).returns(@scope)
      @klass.scope_proxy = @scope_proxy
    end

    it "asks the named_scope_set to add it" do
      @klass.scope(:order! => :name).should == @scope
    end
  end

  describe "adding an association" do
    before do
      @assoc_set             = stub(:add => nil)
      @klass.association_set = @assoc_set
      @klass.has_many :addresses
    end

    it "asks the association set to add it" do
      @assoc_set.should have_received(:add).with(:addresses, {})
    end
  end
end

