source 'https://rubygems.org'

# Specify your gem's dependencies in vagrant-dns.gemspec
gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git"
end

group :plugins do
  gem "vagrant-dns", path: "."
end
