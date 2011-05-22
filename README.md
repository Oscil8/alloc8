Simple distributed resource allocation using Redis.

To use resources:
<pre>
require 'rubygems'
require 'alloc8'

HOST = "my-redis"
PORT = 6379 # default Redis port

puts "acquiring worker"
Alloc8::Tor.with_resource("worker", HOST, PORT) do |worker|
  puts "about to do something with #{worker}"
  # something
end
</pre>

Command-line tool to set up resources:
<pre>
$ alloc8
Tasks:
  alloc8 create CLASS RESOURCE  # Create a resource of a specific class
  alloc8 help [TASK]            # Describe available tasks or one specific task
  alloc8 list CLASS [-A]        # List all instances (or just available) of a resource class
  alloc8 purge CLASS            # Delete all resources from a class
  alloc8 reset CLASS            # Release acquired resources for a class

Options:
  -p, [--port=N]     # Redis store port
                     # Default: 6379
      [--db=N]       # Redis store database number
  -h, [--host=HOST]  # Redis store hostname
                     # Default: localhost

$ export ALLOC8_HOST="my-redis"
$ alloc8 list worker
List entries for worker:
$ alloc8 create worker worker1.my.org
Added worker1.my.org to worker.
$ alloc8 create worker worker2.my.org
Added worker2.my.org to worker.
$ alloc8 list worker
List entries for worker:
  worker1.my.org
  worker2.my.org
</pre>
