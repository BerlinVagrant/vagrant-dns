require 'optparse'
require 'daemons'
require 'rbconfig'

module VagrantDNS

  class Command < Vagrant::Command::Base

    # Runs the vbguest installer on the VMs that are represented
    # by this environment.
    def execute
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant dns [vm-name] [-i|--install] [-u|--uninstall] [-s|--start] [-S|--stop] [-r|--restart]"
        opts.separator ""

        opts.on("--install", "-i", "Install DNS config for machine domain") do
          options[:install] = true
        end

        opts.on("--uninstall", "-u", "Uninstall DNS config for machine domain") do
          options[:uninstall] = true
        end

        opts.on("--start", "-s", "Start the DNS service") do
          options[:start] = true
        end

        opts.on("--stop", "-s", "Stop the DNS service") do
          options[:stop] = true
        end
        
        opts.on("--restart", "-r", "Restart the DNS service") do
          options[:restart] = true
        end
      end

      argv = parse_options(opts)
      return if !argv

      dns_options = []
      
      if argv.empty?
        with_target_vms(nil) { |vm| dns_options << get_dns_options(vm) }
      else
        argv.each do |vm_name|
          with_target_vms(vm_name) { |vm| dns_options << get_dns_options(vm) }
        end
      end

      service = VagrantDNS::Service.new(dns_options)
      
      if options[:start]
        service.start!
      elsif options[:stop]
        service.stop!
      elsif options[:restart]
        service.restart!
      end

      if options[:install] || options[:uninstall]
        if RbConfig::CONFIG["host_os"].match /darwin/
          installer = VagrantDNS::Installers::Mac.new(dns_options)
          
          if options[:install]
            installer.install!
          elsif options[:uninstall]
            installer.uninstall!
          end
        else
          raise 'installing and uninstalling is only supported on Mac OS X at the moment.'
        end
      end
    end

    protected

    def get_dns_options(vm)
      dns_options = vm.config.dns.to_hash
      dns_options[:host_name] = vm.config.vm.host_name
      dns_options[:networks] = vm.config.vm.networks
      dns_options
    end
  end
end