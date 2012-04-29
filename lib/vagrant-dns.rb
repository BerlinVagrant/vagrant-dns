require "vagrant-dns/version"
require "vagrant-dns/command"
require "vagrant-dns/config"
require "vagrant-dns/service"
require "vagrant-dns/installers/mac"
require "vagrant-dns/restart_middleware"
require "vagrant-dns/configurator"

Vagrant.config_keys.register(:dns) { VagrantDNS::Config }

Vagrant.commands.register(:dns) { VagrantDNS::Command }

Vagrant.actions[:start].insert Vagrant::Action::VM::Customize, VagrantDNS::RestartMiddleware