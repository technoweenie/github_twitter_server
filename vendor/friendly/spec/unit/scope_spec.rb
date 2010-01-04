require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Scope" do
  before do
    @klass            = stub
    @scope_parameters = {:name => "Quagmire", :order! => :created_at.desc}
    @scope            = Friendly::Scope.new(@klass, @scope_parameters)
  end

  describe "#all" do
    before do
      @documents = stub
    end

    it "delegates to klass with the scope parameters" do
      @klass.stubs(:all).with(@scope_parameters).returns(@documents)
      @scope.all.should == @documents
    end

    it "merges additional parameters" do
      merged = @scope_parameters.merge(:name => "Joe")
      @klass.stubs(:all).with(merged).returns(@documents)
      @scope.all(:name => "Joe").should == @documents
    end
  end

  describe "#first" do
    before do
      @document = stub
    end

    it "delegates to klass with the scope parameters" do
      @klass.stubs(:first).with(@scope_parameters).returns(@document)
      @scope.first.should == @document
    end

    it "merges additional parameters" do
      merged = @scope_parameters.merge(:name => "Joe")
      @klass.stubs(:first).with(merged).returns(@document)
      @scope.first(:name => "Joe").should == @document
    end
  end

  describe "#paginate" do
    before do
      @documents = stub
    end

    it "delegates to klass with the scope parameters" do
      @klass.stubs(:paginate).with(@scope_parameters).returns(@documents)
      @scope.paginate.should == @documents
    end

    it "merges additional parameters" do
      merged = @scope_parameters.merge(:name => "Joe")
      @klass.stubs(:paginate).with(merged).returns(@documents)
      @scope.paginate(:name => "Joe").should == @documents
    end
  end

  describe "#build" do
    it "instantiates klass with the scope parameters (minus modifiers)" do
      @doc = stub
      @klass.stubs(:new).with(:name => "Quagmire").returns(@doc)
      @scope.build.should == @doc
    end

    it "merges additional parameters" do
      @doc = stub
      @klass.stubs(:new).with(:name => "Fred").returns(@doc)
      @scope.build(:name => "Fred").should == @doc
    end
  end

  describe "#create" do
    it "delegates to klass#create with the scope parameters (minus modifiers)" do
      @doc = stub
      @klass.stubs(:create).with(:name => "Quagmire").returns(@doc)
      @scope.create.should == @doc
    end

    it "merges additional parameters" do
      @doc = stub
      @klass.stubs(:create).with(:name => "Fred").returns(@doc)
      @scope.create(:name => "Fred").should == @doc
    end
  end

  describe "chaining another named scope" do
    before do
      @recent_params = {:order! => :created_at.desc}
      @recent        = Friendly::Scope.new(@klass, @recent_params)
      @klass.stubs(:has_named_scope?).with(:recent).returns(true)
      @klass.stubs(:recent).returns(@recent)
      @scope_params  = {:name => "Joe"}
      @scope         = Friendly::Scope.new(@klass, @scope_params)
    end

    it "responds to the other scope method" do
      @scope.should be_respond_to(:recent)
    end

    it "creates a new scope that merges the two scopes together" do
      merged_parameters = @scope_params.merge(@recent_params)
      @scope.recent.parameters.should == merged_parameters
    end

    it "gives precedence to scopes on the right" do
      @quagmire = Friendly::Scope.new(@klass, :name => "Quagmire")
      (@scope + @quagmire).parameters[:name].should == "Quagmire"
    end
  end
end
