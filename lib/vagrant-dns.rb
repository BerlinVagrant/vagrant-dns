require "vagrant-dns/version"
require "vagrant-dns/config"

require "vagrant-dns/service"
require "vagrant-dns/installers/mac"
require "vagrant-dns/restart_middleware"
require "vagrant-dns/configurator"

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
        hook.append VagrantDNS::RestartMiddleware
      end
    end

  end

end
