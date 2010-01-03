require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Query" do
  before do
    @order = :created_at.desc
    @query = Friendly::Query.new(:name            => "x",
                                 :limit!          => 10,
                                 :order!          => @order,
                                 :preserve_order! => true,
                                 :offset!         => 2)
  end

  it "extracts the conditions" do
    @query.conditions.should == {:name => "x"}
  end

  it "extracts the limit parameter" do
    @query.limit.should == 10
  end

  it "extracts the order parameter" do
    @query.order.should == @order
  end

  it "extracts the preserve order parameter" do
    @query.should be_preserve_order
  end

  it "extracts the offset parameter" do
    @query.should be_offset
    @query.offset.should == 2
  end

  it "should not be preserver order by default" do
    Friendly::Query.new({}).should_not be_preserve_order
  end

  it "converts string representations of UUID to UUID" do
    uuid       = stub
    uuid_klass = stub
    uuid_klass.stubs(:new).with("asdf").returns(uuid)
    query      = Friendly::Query.new({:id => "asdf"}, uuid_klass)
    query.conditions[:id].should == uuid
  end

  it "converts arrays of ids to UUID" do
    uuid       = stub
    uuid_klass = stub
    uuid_klass.stubs(:new).with("asdf").returns(uuid)
    query      = Friendly::Query.new({:id => ["asdf"]}, uuid_klass)
    query.conditions[:id].should == [uuid]
  end

  describe "a pagination query" do
    describe "page nil" do
      before do
        @query = Friendly::Query.new(:page!     => nil,
                                     :per_page! => 5)
      end

      it "is page 1" do
        @query.page.should == 1
      end

      it "has an offset of 0" do
        @query.offset.should == 0
      end

      it "has a limit of :per_page" do
        @query.limit.should == 5
      end
    end

    describe "page 2" do
      before do
        @query = Friendly::Query.new(:page!     => 2,
                                     :per_page! => 5)
      end

      it "has an offset of :per_page * page-1" do
        @query.offset.should == 5
      end

      it "has a limit of :per_page" do
        @query.limit.should == 5
      end
    end

    describe "when page is a string" do
      before do
        @query = Friendly::Query.new(:page!     => "2",
                                     :per_page! => 5)
      end

      it "has an offset of :per_page * page-1" do
        @query.offset.should == 5
      end

      it "has a limit of :per_page" do
        @query.limit.should == 5
      end
    end
  end
end
