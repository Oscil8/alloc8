Simple distributed resource allocation using Redis.

<pre>
require 'alloc8'

HOST = "my-redis"
PORT = 6379 # default Redis port

# to create resources
@allocator = Alloc8::Tor.new(HOST, PORT)
@allocator.create("worker", "worker1.my.org")
@allocator.create("worker", "worker2.my.org")

# to use them
Alloc8::Tor.with_resource("worker", HOST, PORT) do |worker|
  # something
end
</pre>