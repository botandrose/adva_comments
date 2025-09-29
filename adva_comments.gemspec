# -*- encoding: utf-8 -*-
require File.expand_path('../lib/adva_comments/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Micah Geisel"]
  gem.email         = ["micah@botandrose.com"]
  gem.description   = %q{Adva Comments}
  gem.summary       = %q{Engine for Adva CMS commenting component}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "adva_comments"
  gem.require_paths = ["lib"]
  gem.version       = AdvaComments::VERSION

  gem.add_dependency "adva"
  gem.add_dependency "validates_email_format_of"
  gem.add_dependency "invisible_captcha"

  gem.add_development_dependency "rspec", ">= 3.12", "< 4.0"
  gem.add_development_dependency "rspec-rails", ">= 6.1", "< 8.0"
  gem.add_development_dependency "rails", ">= 7.2", "< 9.0"
  gem.add_development_dependency "sqlite3", "~> 2.1"
  gem.add_development_dependency "simplecov", "~> 0.22"
  gem.add_development_dependency "simplecov-html", "~> 0.13"
  gem.add_development_dependency "shoulda-matchers", "~> 6.0"
end
