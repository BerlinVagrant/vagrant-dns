source 'https://rubygems.org'
ruby(ENV['TEST_RUBY_VERSION'] || '~> 2.4.4')

ENV['TEST_VAGRANT_VERSION'] ||= 'v2.1.4'

# Using the :plugins group causes Vagrant to automagially load auto_network
# during acceptance tests.
group :plugins do
  gemspec
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

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
