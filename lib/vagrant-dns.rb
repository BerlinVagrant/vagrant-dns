require "vagrant-dns/version"
require "vagrant-dns/command"
require "vagrant-dns/config"
require "vagrant-dns/service"
require "vagrant-dns/installers/mac"

Vagrant.config_keys.register(:dns) { VagrantDNS::Config }

Vagrant.commands.register(:dns) { VagrantDNS::Command }