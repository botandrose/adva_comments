# -*- encoding: utf-8 -*-
require File.expand_path('../lib/has_counter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Micah Geisel"]
  gem.email         = ["micah@botandrose.com"]
  gem.description   = %q{Simple counter cache helper for ActiveRecord with flexible callbacks.}
  gem.summary       = %q{Lightweight counter cache extension for ActiveRecord.}
  gem.homepage      = "https://example.com/has_counter"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "has_counter"
  gem.require_paths = ["lib"]
  gem.version       = HasCounter::VERSION
end
