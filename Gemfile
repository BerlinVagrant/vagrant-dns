source 'https://rubygems.org'
ruby(ENV['TEST_RUBY_VERSION'] || '~> 2.3.4')

ENV['TEST_VAGRANT_VERSION'] ||= 'v1.9.6'

# Using the :plugins group causes Vagrant to automagially load auto_network
# during acceptance tests.
group :plugins do
  gemspec
end

group :test, :development do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant', :branch => 'master'
  else
    gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant', :tag => ENV['TEST_VAGRANT_VERSION']
  end
  gem 'rubydns', '~> 2.0.0.pre.rc2'
end

group :test do
  gem 'vagrant-spec', :git => 'https://github.com/mitchellh/vagrant-spec'
  gem 'rake'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
