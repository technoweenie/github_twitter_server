require File.expand_path("../../../spec_helper", __FILE__)

describe "Friendly::Associations::Association" do
  before do
    @owner_klass = stub(:name => "User")
    @klass       = stub
    # FIXME: ugh.
    String.any_instance.stubs(:constantize).returns(@klass)
    @assoc_klass = Friendly::Associations::Association
  end

  describe "with defaults" do
    before do
      @association = @assoc_klass.new(@owner_klass, :addresses)
    end

    it "has a default klass of name.classify.constantize" do
      @association.klass.should == @klass
    end

    it "has a foreign_key of owner_klass.name.singularize + '_id'" do
      @association.foreign_key.should == :user_id
    end

    it "returns a scope on klass of {:foreign_key => document.id}" do
      @scope = stub
      @klass.stubs(:scope).with(:user_id => 42).returns(@scope)

      @association.scope(stub(:id => 42)).should == @scope
    end
  end

  describe "with overridden attributes" do
    before do
      @klass      = stub
      @class_name = "SomeOtherClass"
      @class_name.stubs(:constantize).returns(@klass)
      @association = @assoc_klass.new @owner_klass, :whatever, 
                                      :class_name  => @class_name,
                                      :foreign_key => :other_id
    end

    it "uses the overridden class_name to get the class" do
      @association.klass.should == @klass
    end

    it "uses the overridden foreign_key" do
      @association.foreign_key.should == :other_id
    end

    it "uses the override foreign_key in the scope" do
      @scope = stub
      @klass.stubs(:scope).with(:other_id => 42).returns(@scope)
      @association.scope(stub(:id => 42)).should == @scope
    end
  end
end
