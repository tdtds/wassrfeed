# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wassrfeed/version"

Gem::Specification.new do |s|
  s.name        = "wassrfeed"
  s.version     = WassrFeed::VERSION
  s.authors     = ["TADA Tadashi"]
  s.email       = ["t@tdtds.jp"]
  s.homepage    = "http://github.com/tdtds/wassrfeed"
  s.summary     = %q{Posting feed items to wassr}
  s.description = %q{A command to post from RSS feed to Wassr.}

  s.rubyforge_project = "wassrfeed"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "pit"
end
