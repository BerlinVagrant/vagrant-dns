require 'optparse'
require 'daemons'
require 'rbconfig'

module VagrantDNS

  class Command < Vagrant.plugin(2, :command)

    # Runs the vbguest installer on the VMs that are represented
    # by this environment.
    def execute
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant dns [vm-name] [-i|--install] [-u|--uninstall] [--pruge] [-s|--start] [-S|--stop] [-r|--restart] [-o|--ontop]"
        opts.separator ""

        opts.on("--install", "-i", "Install DNS config for machine domain") do
          options[:install] = true
        end

        opts.on("--uninstall", "-u", "Uninstall DNS config for machine domain") do
          options[:uninstall] = true
        end

        opts.on("--purge", "Uninstall DNS config and remove DNS configurations of all machines.") do
          options[:uninstall] = true
          options[:purge] = true
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

        opts.on("--ontop", "-o", "Start the DNS service on top. Debugging only, this blocks Vagrant!") do
          options[:ontop] = true
        end
      end

      argv = parse_options(opts)
      return if !argv

      vms = argv unless argv.empty?

      if options[:uninstall]
        manage_service(vms, options.merge(stop: true))
        manage_installation(vms, options)

        if options[:purge]
          require 'fileutils'
          FileUtils.rm_r(tmp_path)
        end
      else
        build_config(vms, options)
        manage_service(vms, options)
        manage_installation(vms, options) if options[:install]
      end

    end

    protected

    def manage_installation(vms, options)
      if RbConfig::CONFIG["host_os"].match /darwin/
        installer = VagrantDNS::Installers::Mac.new(tmp_path)

        if options[:install]
          installer.install!
        elsif options[:uninstall]
          installer.uninstall!
        end
      else
        raise 'installing and uninstalling is only supported on Mac OS X at the moment.'
      end
    end

    def manage_service(vms, options)
      service = VagrantDNS::Service.new(tmp_path, options)

      if options[:start]
        service.start!
      elsif options[:stop]
        service.stop!
      elsif options[:restart]
        service.restart!
      end
    end

    def build_config(vms, options)
      with_target_vms(vms) { |vm| VagrantDNS::Configurator.new(vm, tmp_path).run! }
    end

    def tmp_path
      File.join(@env.tmp_path, "dns")
    end
  end
end
