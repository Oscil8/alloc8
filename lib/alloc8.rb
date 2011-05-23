require 'redis'

module Alloc8
  class Tor
    # initialize connection to redis
    def initialize(host, port, db=nil)
      @redis = Redis.new(:host => host, :port => port)
      @redis.select(db) if db
    end

    # create a resource in a class
    def create(klass, resource)
      if @redis.sadd(key(klass), resource.to_s)
        @redis.lpush key(klass, :avail), resource.to_s
      end
    end

    # list all resources in class
    def list(klass)
      @redis.smembers(key(klass))
    end

    # delete a resource class
    def purge(klass)
      nkeys = @redis.del key(klass, :avail), key(klass)
      nkeys == 2 # true if purged all
    end

    # reset available items in resource class
    def reset(klass)
      akey = key(klass, :avail)
      @redis.del akey
      @redis.smembers(key(klass)).each do |resource|
        @redis.lpush akey, resource.to_s
      end
    end

    # list all available items in resource class
    def available(klass)
      akey = key(klass, :avail)
      avail = []
      @redis.llen(akey).times do |i|
        avail << @redis.lindex(akey, i)
      end
      avail
    end

    # acquire next available resource
    def acquire(klass, timeout = 0)
      akey, res = @redis.brpop key(klass, :avail), timeout
      res
    end

    # return resource
    def return(klass, resource)
      raise Exception.new("Invalid resource #{resource} for class #{klass}") if !@redis.sismember key(klass), resource.to_s
      @redis.lpush key(klass, :avail), resource.to_s
    end

    # block to allocate a resource
    def self.with_resource(klass, host, port, db=nil)
      a = Alloc8::Tor.new host, port, db
      begin
        res = a.acquire(klass)
        yield res
      ensure
        a.return(klass, res)
      end
    end

    private
    def key(klass, suffix = nil)
      "resource:#{klass}" << (suffix ? suffix.to_s : "")
    end
  end
end
