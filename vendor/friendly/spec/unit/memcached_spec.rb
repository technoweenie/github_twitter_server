require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly::Memcached" do
  before do
    @cache     = stub(:set => nil)
    @memcached = Friendly::Memcached.new(@cache)
  end

  describe "setting a key" do
    before do
      @memcached.set("key", "value")
    end

    it "sets the key in memcached" do
      @cache.should have_received(:set).with("key", "value")
    end
  end

  describe "getting an existing key" do
    before do
      @cache.stubs(:get).with("Some Key").returns("Some Value")
    end

    it "returns the value from cache" do
      @memcached.get("Some Key").should == "Some Value"
    end
  end

  describe "getting a missing key" do
    before do
      @cache.stubs(:get).raises(Memcached::NotFound)
    end

    describe "with no block supplied" do
      it "returns nil if no block is supplied" do
        @memcached.get("Some Key").should be_nil
      end
    end

    describe "with a block" do
      before do
        @returned = @memcached.get("Some Key") { "THE VALUE!" }
      end

      it "returns the value of the supplied block" do
        @returned.should == "THE VALUE!"
      end

      it "sets the key to that value" do
        @cache.should have_received(:set).with("Some Key", "THE VALUE!")
      end
    end
  end

  describe "getting multiple keys" do
    describe "when all keys are found" do
      before do
        @hits = {"a" => "foo", "b" => "bar", "c" => "baz"}
        @keys = ["a", "b", "c"]
        @cache.stubs(:get).with(@keys).returns(@hits)
      end

      it "delegates to the cache object" do
        @memcached.multiget(@keys).should == @hits
      end
    end

    describe "when only some of the keys are found" do
      before do
        @hits = {"a" => "foo", "b" => "bar"}
        @keys = ["a", "b", "c"]
        @cache.stubs(:get).with(@keys).returns(@hits)
        @returned = @memcached.multiget(@keys) { |k| "#{k}/fromblock" }
      end

      it "fetches the rest of the keys by yielding to the block" do
        @returned.should == @hits.merge("c" => "c/fromblock")
      end

      it "sets the missing keys in the cache" do
        @cache.should have_received(:set).with("c", "c/fromblock")
      end
    end

    describe "when the list of keys is empty" do
      it "returns {}" do
        @memcached.multiget([]).should == {}
      end
    end
  end

  describe "deleting" do
    describe "an existing key" do
      before do
        @cache.stubs(:delete).returns(nil)
        @memcached.delete("some key")
      end

      it "asks the cache to delete" do
        @cache.should have_received(:delete).with("some key")
      end
    end

    describe "a missing key" do
      before do
        @cache.stubs(:delete).raises(Memcached::NotFound)
      end

      it "just returns nil" do
        lambda { @memcached.delete("some key") }.should_not raise_error
      end
    end
  end
end
