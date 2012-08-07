# -*- encoding: utf-8 -*-
require File.expand_path('../lib/muster/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christopher H. Laco"]
  gem.email         = ["claco@chrislaco.com"]
  gem.description   = %q{Muster is a gem that turns query strings of varying formats into data structures suitable for easier consumption in AR/DataMapper scopes and queries.}
  gem.summary       = %q{Muster various query string formats into a more reusable data structure.}
  gem.homepage      = "https://github.com/claco/muster"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "muster"
  gem.require_paths = ["lib"]
  gem.version       = Muster::VERSION

  gem.add_dependency 'activesupport', '~> 3.0'
  gem.add_dependency 'rack',          '~> 1.4'

  gem.add_development_dependency 'rspec',     '~> 2.11.0'
  gem.add_development_dependency 'redcarpet', '~> 2.1'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard',      '~> 0.8.2'
end
