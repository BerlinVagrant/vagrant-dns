require "vagrant-dns/version"
require "vagrant-dns/config"

require "vagrant-dns/registry"
require "vagrant-dns/service"
require "vagrant-dns/installers/mac"
require "vagrant-dns/configurator"
require "vagrant-dns/middlewares/config_up"
require "vagrant-dns/middlewares/config_down"
require "vagrant-dns/middlewares/restart"

module VagrantDNS

  # @private
  def self.hooks
    @hooks ||= []
  end

  # @private
  def self.hooked(name)
    hooks << name
  end

  # @private
  def self.hooked?(name)
    hooks.include?(name)
  end

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
      action_hook("restart_vagarant_dns_on_#{action}", action) do |hook|
        unless VagrantDNS.hooked?(action)
          hook.append VagrantDNS::Middlewares::ConfigUp
          hook.append VagrantDNS::Middlewares::Restart
          VagrantDNS.hooked(action)
        end
      end
    end

    action_hook("remove_vagrant_dns_config", "machine_action_destroy") do |hook|
      unless VagrantDNS.hooked?("remove_vagrant_dns_config")
        hook.append VagrantDNS::Middlewares::ConfigDown
        hook.append VagrantDNS::Middlewares::Restart
        VagrantDNS.hooked("remove_vagrant_dns_config")
      end
    end
  end

end
