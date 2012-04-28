# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"
  
  config.dns.patterns = /^.*machine.dev$/
  
  config.vm.host_name = "machine"
  config.vm.network :hostonly, "33.33.33.60"

  
  VagrantDNS::Config.logger = Logger.new("dns.log")
  VagrantDNS::Config.listen = [[:udp, "0.0.0.0", 5300]]
end
