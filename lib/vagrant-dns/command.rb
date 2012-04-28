require 'optparse'
require 'daemons'

module VagrantDNS

  class Command < Vagrant::Command::Base

    # Runs the vbguest installer on the VMs that are represented
    # by this environment.
    def execute
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant dns [vm-name] [-i|--install] [-u|--uninstall] [-s|--start] [-S|--stop]"
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
      
      if options[:start]
        run_options = {:ARGV => ["start"]}
      elsif options[:stop]
        run_options = {:ARGV => ["stop"]}
      end
      
      if options[:start] || options[:stop]        
        Daemons.run_proc("dnsserver.rb", run_options) do
          require 'rubydns'

          RubyDNS::run_server(:listen => VagrantDNS::Config.listen) do
            self.logger = VagrantDNS::Config.logger if VagrantDNS::Config.logger
            
            dns_options.each do |opts|
              pattern = /^.*#{opts[:host_name]}.#{opts[:tld]}$/

              network = opts[:networks].first
              ip = network.last.first

              action = lambda { |match_data, transaction| transaction.respond!(ip) }

              match(pattern, :A, &action)
              match(pattern, :AAAA, &action)
            end
          end
        end
      end
      
      if options[:install]
        require 'fileutils'
        dns_options.each do |opts|
          port = VagrantDNS::Config.listen.first.last
          tld = opts[:tld]
          contents = <<-FILE
nameserver 127.0.0.1
port #{port}
FILE
          FileUtils.mkdir_p("/etc/resolver")
          File.open(File.join("/etc/resolver", tld), "w") do |f|
            f << contents
          end
        end
      end
      
      if options[:uninstall]
        require 'fileutils'
        
        dns_options.each do |opts|
          tld = opts[:tld]
          FileUtils.rm(File.join("/etc/resolver", tld))
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