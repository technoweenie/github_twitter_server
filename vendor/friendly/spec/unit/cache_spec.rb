require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Cache" do
  describe "getting a cache object for :id" do
    before do
      @cache = Friendly::Cache.cache_for(stub, [:id], {})
    end

    it "instantiates a Cache::ByID" do
      @cache.should be_instance_of(Friendly::Cache::ByID)
    end
  end

  describe "for other fields" do
    it "raises NotSupported" do
      lambda {
        Friendly::Cache.cache_for(stub, [:asdf], {})
      }.should raise_error(Friendly::NotSupported)
    end
  end
end
