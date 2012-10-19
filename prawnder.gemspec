# -*- encoding: utf-8 -*-
require File.expand_path('../lib/prawnder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dave McNelis"]
  gem.email         = ["davemcnelis@market76.com"]
  gem.description   = %q{
Rails Prawn PDF renderer support compatible with Rails 3.

* Adds view templates with direct Prawn document methods.
* Allows for nested partials
* Supports passing locals to partials
}
  gem.summary       = %q{
Rails Prawn PDF renderer support compatible with Rails 3.
}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "prawnder"
  gem.require_paths = ["lib"]
  gem.version       = Prawnder::VERSION
end
