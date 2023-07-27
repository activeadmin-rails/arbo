# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "arbo/version"

Gem::Specification.new do |s|
  s.name        = "arbo"
  s.version     = Arbo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Piers Chambers"]
  s.email       = ["piers@varyonic.com"]
  s.homepage    = ""
  s.summary     = %q{Forked from Greg Bell's 'Arbre', An Object Oriented DOM Tree in Ruby}
  s.description = %q{Forked from Greg Bell's 'Arbre', An Object Oriented DOM Tree in Ruby}
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.5'

  s.add_dependency("activesupport", ">= 3.0.0")
  s.add_dependency("ruby2_keywords", ">= 0.0.2")
end
