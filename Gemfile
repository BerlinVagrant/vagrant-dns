source 'https://rubygems.org'
ruby(ENV['TEST_RUBY_VERSION'] || '~> 2.2.6')

ENV['TEST_VAGRANT_VERSION'] ||= 'v1.9.3'

# Using the :plugins group causes Vagrant to automagially load auto_network
# during acceptance tests.
group :plugins do
  gemspec
end

group :test, :development do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', :github => 'mitchellh/vagrant', :branch => 'master'
  else
    gem 'vagrant', :github => 'mitchellh/vagrant', :tag => ENV['TEST_VAGRANT_VERSION']
  end
  gem 'rubydns', '~> 2.0.0.pre.rc1'
end

group :test do
  gem 'vagrant-spec', :git => 'https://github.com/mitchellh/vagrant-spec'
  gem 'rake'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
