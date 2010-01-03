require File.expand_path("../../spec_helper", __FILE__)

describe "Writing through to cache on create" do
  before do
    @address = Address.create :street => "Spooner"
  end
  
  it "writes through to memcache using the model street and guid as cache key" do
    $cache.get("Address/0/#{@address.id.to_guid}").should == @address
  end
end

describe "Writing with a version number" do
  before do
    Address.storage_proxy.caches.clear
    Address.caches_by :id, :version => 1
    @address = Address.create :street => "Spooner"
  end

  after do
    Address.storage_proxy.caches.clear
    Address.caches_by :id
  end

  it "adds the version number to the cache key" do
    $cache.get("Address/1/#{@address.id.to_guid}").should == @address
  end
end

describe "Writing through to cache on update" do
  before do
    @address = Address.create :street => "Spooner"
    @address.street = "Joe"
    @address.save
  end
  
  it "writes through to memcache using the model street and guid as cache key" do
    $cache.get("Address/0/#{@address.id.to_guid}").street.should == @address.street
  end
end

describe "Writing through to cache on destroy" do
  before do
    @address = Address.create :street => "Spooner"
    @address.destroy
  end
  
  it "removes the object from cache" do
    lambda {
      $cache.get("Address/0/#{@address.id.to_guid}") 
    }.should raise_error(Memcached::NotFound)
  end
end
