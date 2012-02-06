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

  s.files         = `if [ -d .git ]; then git ls-files; fi`.split("\n")
  s.test_files    = `if [ -d .git ]; then git ls-files -- {test,spec,features}/*; fi `.split("\n")
  s.executables   = `if [ -d .git ]; then git ls-files -- bin/*; fi`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake',  '~> 0.9.2'
  s.add_dependency 'slop',              '2.4.3'
  s.add_dependency 'highline',          '1.6.11'
  s.add_dependency 'mechanize',         '2.1'
  s.add_dependency 'activeresource',    '< 3.1.0'

end
