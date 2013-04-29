# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vagrant-dns/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Florian Gilcher"]
  gem.email         = ["florian.gilcher@asquera.de"]
  gem.description   = %q{vagrant-dns is a vagrant plugin that manages DNS records associated with local machines.}
  gem.summary       = %q{vagrant-dns manages DNS records of vagrant machines}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vagrant-dns"
  gem.require_paths = ["lib"]
  gem.version       = Vagrant::Dns::VERSION

  gem.add_dependency "daemons"
  gem.add_dependency "rubydns", "~> 0.6.0"
end
