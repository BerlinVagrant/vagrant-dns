source 'https://rubygems.org'
ruby(File.read(File.expand_path('.ruby-version', __dir__))[/\d+\.\d+\.\d+.*/])

ENV['TEST_VAGRANT_VERSION'] ||= 'v2.3.4'

# Using the :plugins group causes Vagrant to automagially load auto_network
# during acceptance tests.
group :plugins do
  gemspec
  # source "https://gems.hashicorp.com/" do
  #   gem "vagrant-vmware-desktop"
  # end
end

group :test, :development do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', :git => 'https://github.com/hashicorp/vagrant', :branch => 'main'
  else
    gem 'vagrant', :git => 'https://github.com/hashicorp/vagrant', :tag => ENV['TEST_VAGRANT_VERSION']
  end
  gem 'rubydns', '~> 2.0.0'
end

group :test do
  gem 'vagrant-spec', :git => 'https://github.com/hashicorp/vagrant-spec', :branch => 'main'
  gem 'rake'
end

if File.exist? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
