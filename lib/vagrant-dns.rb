require "vagrant-dns/version"
require "vagrant-dns/config"

require "vagrant-dns/store"
require "vagrant-dns/registry"
require "vagrant-dns/tld_registry"
require "vagrant-dns/service"
require "vagrant-dns/installers"
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

    %w{machine_action_up machine_action_reload}.each do |action|
      action_hook("restart_vagarant_dns_on_#{action}", action) do |hook, *args|
        hook_once VagrantDNS::Middlewares::ConfigUp, hook
        hook_once VagrantDNS::Middlewares::Restart, hook
      end
    end

    action_hook("remove_vagrant_dns_config", "machine_action_destroy") do |hook|
      hook_once VagrantDNS::Middlewares::ConfigDown, hook
      hook_once VagrantDNS::Middlewares::Restart, hook
    end

    # @private
    def self.hook_once(middleware, hook)
      return if hook.append_hooks.any? { |stack_item|
        if stack_item.is_a?(Array)
          stack_item.first == middleware
        else
          stack_item.middleware == middleware
        end

      }
      hook.append middleware
    end
  end

end
