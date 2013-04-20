require "vagrant-dns/version"
require "vagrant-dns/service"
require "vagrant-dns/installers/mac"
require "vagrant-dns/restart_middleware"
require "vagrant-dns/configurator"

module VagrantDNS

  class VagrantDns < Vagrant.plugin("2")

    name "vagrant-dns"

    config "dns" do
      require File.expand_path("../vagrant-dns/config", __FILE__)
      Config
    end

    command "dns" do
      require File.expand_path("../vagrant-dns/command", __FILE__)
      Command
    end

    action_hook(self::ALL_ACTIONS) do |hook|
      hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, VagrantDNS::RestartMiddleware)
    end

  end

end
