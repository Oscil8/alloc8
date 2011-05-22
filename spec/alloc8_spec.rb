require 'alloc8'

describe Alloc8 do
  KIND = "ResourceClass"
  HOST = "localhost"
  PORT = 6379 # default redis port

  before {
    @allocator = Alloc8::Tor.new(HOST, PORT)
    @allocator.purge(KIND)
  }

  context "having no resources" do
    it "can create a resource" do
      @allocator.create(KIND, "a").should == 1
    end
  end

  context "having a single resource" do
    before { @allocator.create KIND, "a" }

    it "can return a list of resources, available resources" do
      @allocator.list(KIND).should eq(["a"])
      @allocator.available(KIND).should eq(["a"])
    end

    it "can't allocate it again" do
      @allocator.create(KIND, "a").should == nil
    end

    it "can allocate other resources" do
      @allocator.create(KIND, "b").should == 2
      @allocator.create(KIND, "c").should == 3
    end

    it "can purge resource class" do
      @allocator.purge(KIND).should == true
    end

    it "can acquire and return a resource" do
      @allocator.acquire(KIND).should == "a"
      @allocator.return(KIND, "a").should == 1
    end

    it "can't return an invalid resource" do
      lambda { @allocator.return(KIND, "foo") }.should raise_error
    end

    it "can acquire with a block" do
      Alloc8::Tor.with_resource(KIND, HOST, PORT) do |res|
        res.should == "a"
      end
    end

    it "can't acquire a second resource" do
      @allocator.acquire(KIND)
      @allocator.acquire(KIND, 1).should == nil # with 1s timeout
    end
  end

  context "having multiple resources" do
    before { ["a", "b", "c"].each {|r| @allocator.create KIND, r} }

    it "can return a list of resources, available resources" do
      @allocator.list(KIND).should include("a", "b", "c")
      @allocator.available(KIND).should include("a", "b", "c")
    end

    it "can purge resource class" do
      @allocator.purge(KIND).should == true
    end

    it "can acquire and return multiple resources" do
      @allocator.acquire(KIND).should == "a"
      @allocator.acquire(KIND).should == "b"
      @allocator.acquire(KIND).should == "c"
      @allocator.return(KIND, "c").should == 1
      @allocator.return(KIND, "b").should == 2
      @allocator.return(KIND, "a").should == 3
    end
  end

end
