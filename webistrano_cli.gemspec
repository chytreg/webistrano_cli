# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "webistrano_cli/version"

Gem::Specification.new do |s|
  s.name        = "webistrano_cli"
  s.version     = WebistranoCli::VERSION
  s.authors     = ["chytreg"]
  s.email       = ["dariusz.gertych@gmail.com"]
  s.homepage    = "https://github.com/chytreg/webistrano_cli"
  s.summary     = %q{Allow to deploy projects from webistrano via console}
  s.description = %q{Allow to deploy projects from webistrano via console}

  s.rubyforge_project = "webistrano_cli"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rake'
  s.add_dependency 'thor'
  s.add_dependency 'highline'
  s.add_dependency 'mechanize'
  s.add_dependency 'activeresource', '< 3.1.0'

end
