# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exact-target-api/version'

Gem::Specification.new do |gem|
  gem.name          = 'exact-target-api'
  gem.version       = ET::VERSION
  gem.authors       = ['Alexander Shapiotko', 'BriteVerify']
  gem.email         = ['support@briteverify.com']
  gem.description   = 'ExactTarget API wrapper'
  gem.summary       = 'ExactTarget API wrapper'
  gem.homepage      = 'https://github.com/BriteVerify/exact-target-api'

  gem.add_dependency 'nokogiri', '~> 1.13.3'
  gem.add_dependency 'savon', '~> 2.12.1'
  gem.add_dependency 'jwt', '~> 2.2.3'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
