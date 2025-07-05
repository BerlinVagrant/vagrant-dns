# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vagrant-dns/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Florian Gilcher", "Robert Schulze"]
  gem.email         = ["florian.gilcher@asquera.de", "robert@dotless.de"]
  gem.description   = %q{vagrant-dns is a vagrant plugin that manages DNS records associated with local machines.}
  gem.summary       = %q{vagrant-dns manages DNS records of vagrant machines}
  gem.homepage      = "https://github.com/BerlinVagrant/vagrant-dns"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\).reject { |f| f.match(%r{^(test|testdrive)/}) }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vagrant-dns"
  gem.require_paths = ["lib"]
  gem.version       = VagrantDNS::VERSION

  gem.metadata = {
    "bug_tracker_uri" => "https://github.com/BerlinVagrant/vagrant-dns/issues",
    "changelog_uri"   => "https://github.com/BerlinVagrant/vagrant-dns/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/BerlinVagrant/vagrant-dns",
    "wiki_uri"        => "https://github.com/BerlinVagrant/vagrant-dns/wiki"
  }

  gem.required_ruby_version = '>= 3.3.5'

  gem.add_dependency "daemons"
  gem.add_dependency "rubydns", '~> 2.1.1'
  gem.add_dependency "public_suffix"

  # Pinning transient dependencies of `rubydns` to avoid
  # ruby version compatibility issues.
  gem.add_dependency "async-dns", '~> 1.4.1'
  gem.add_dependency 'async', '~> 2.25.0'

  gem.add_development_dependency 'rspec'
end
