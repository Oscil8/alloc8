# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "alloc8/version"

Gem::Specification.new do |s|
  s.name        = "alloc8"
  s.version     = Alloc8::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ariel Salomon"]
  s.email       = ["ariel@oscillatory.org"]
  s.homepage    = ""
  s.summary     = %q{Simple distributed resource allocator based on Redis}
  s.description = %q{Simple distributed resource allocation using Redis.
    Alloc8::Tor.with_resource do ...}

  s.rubyforge_project = "alloc8"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "redis", "~> 2.2.0"
  s.add_development_dependency "rspec", "~> 2.0"
end
