require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::NamedScope" do
  before do
    @klass       = stub
    @scope       = stub
    @scope_klass = stub
    @parameters  = {:name => "James"}
    @scope_klass.stubs(:new).with(@klass, @parameters).returns(@scope)
    @named_scope = Friendly::NamedScope.new(@klass, @parameters, @scope_klass)
  end

  it "provides scope instances with the given parameters" do
    @named_scope.scope.should == @scope
  end
end
