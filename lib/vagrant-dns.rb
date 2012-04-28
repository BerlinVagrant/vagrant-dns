require "vagrant-dns/version"
require "vagrant-dns/command"
require "vagrant-dns/config"

Vagrant.config_keys.register(:dns) { VagrantDNS::Config }

Vagrant.commands.register(:dns) { VagrantDNS::Command }