# -*- encoding: utf-8 -*-

require File.expand_path('../lib/bank_routing/version', __FILE__)

Gem::Specification.new do |gem|
	gem.name          = "bank_routing"
	gem.version       = BankRouting::VERSION
	gem.summary       = %q{Exposes bank routing information.}
	gem.description   = %q{Pulls in a ton of data from the Federal Reserve and other places to provide an interface to a whole bunch of information about bank routing numbers.}
	gem.license       = "MIT"
	gem.authors       = ["Cozy"]
	gem.email         = "oss@cozy.co"
	gem.homepage      = "https://github.com/CozyCo/bank_routing"

	gem.files         = `git ls-files`.split($/)
	gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
	gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
	gem.require_paths = ['lib']

	gem.add_development_dependency 'bundler', '~> 1.2'
	gem.add_development_dependency 'rake', '~> 10.0'
	gem.add_development_dependency 'rspec', '~> 2.4'
	gem.add_development_dependency 'yard', '~> 0.8'
	gem.add_development_dependency 'redis'
	
	gem.add_dependency 'typhoeus', '~> 0.6'
	gem.add_dependency 'yajl-ruby', '~> 1.2'
	
end
