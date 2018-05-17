require "vagrant-dns/version"
require "vagrant-dns/config"

require "vagrant-dns/service"
require "vagrant-dns/installers/mac"
require "vagrant-dns/registry"
require "vagrant-dns/configurator"
require "vagrant-dns/middlewares/config_up"
require "vagrant-dns/middlewares/config_down"
require "vagrant-dns/middlewares/restart"

module VagrantDNS

  class Plugin < Vagrant.plugin("2")

    name "vagrant-dns"

    config "dns" do
      Config
    end

    command "dns" do
      require File.expand_path("../vagrant-dns/command", __FILE__)
      Command
    end

    %w{up reload}.each do |action|
      action_hook(:restart_host_dns, "machine_action_#{action}".to_sym) do |hook|
        hook.append VagrantDNS::Middlewares::ConfigUp
        hook.append VagrantDNS::Middlewares::Restart
      end
    end

    action_hook(:remove_dns_config, :machine_action_destroy) do |hook|
      hook.append VagrantDNS::Middlewares::ConfigDown
      hook.append VagrantDNS::Middlewares::Restart
    end
  end

end
