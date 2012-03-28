# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jangosmtp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brennon Loveless"]
  gem.email         = ["brennon@fritzandandre.com"]
  gem.description   = %q{Library for interfacing with JangoSMTP}
  gem.summary       = %q{Will encapsulate all the necessary api calls into an easy to use gem.}
  gem.homepage      = "https://github.com/jbrennon/jangosmtp"

  gem.add_dependency 'mechanize', '~> 2.3'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jangosmtp"
  gem.require_paths = ["lib"]
  gem.version       = Jangosmtp::VERSION
end
