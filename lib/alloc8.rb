require 'redis'

module Alloc8
  class Tor
    # initialize connection to a redis
    def initialize(host, port, db=nil)
      @redis = Redis.new(:host => host, :port => port)
      @redis.select(db) if db
    end

    # create a resource in a class
    def create(resource_class, resource)
      if @redis.sadd("resource:#{resource_class}", resource.to_s)
        @redis.lpush "resource:#{resource_class}:avail", resource.to_s
      end
    end

    # delete a resource
    def purge(resource_class)
      nkeys = @redis.del "resource:#{resource_class}:avail", "resource:#{resource_class}"
      nkeys == 2 # true if purged all
    end

    # reset available items in resource class
    def reset(resource_class)
      @redis.del "resource:#{resource_class}:avail"
      @redis.smembers("resource:#{resource_class}").each do |resource|
        @redis.lpush "resource:#{resource_class}:avail", resource.to_s
      end
    end

    # acquire next available resource
    def acquire(resource_class, timeout = 0)
      key, res = @redis.brpop "resource:#{resource_class}:avail", timeout
      res
    end

    # return resource
    def return(resource_class, resource)
      raise Exception if !@redis.sismember "resource:#{resource_class}", resource.to_s
      @redis.lpush "resource:#{resource_class}:avail", resource.to_s
    end

    # block to allocate a resource
    def self.with_resource(resource_class, host, port, db=nil)
       a = Alloc8::Tor.new host, port, db
       res = a.acquire(resource_class)
       yield res
       a.return(resource_class, res)
    end
  end
end
