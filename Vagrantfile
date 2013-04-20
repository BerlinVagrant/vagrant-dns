# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"

  config.dns.tld = "dev"
  config.dns.patterns = /^.*machine.dev$/

  config.vm.hostname = "machine"
  config.vm.network :private_network, ip: "33.33.33.60"

  
  VagrantDNS::Config.listen = [[:udp, "0.0.0.0", 5300]]
end
