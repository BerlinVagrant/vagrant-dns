require 'daemons'

module VagrantDNS
  class Service
    attr_accessor :tmp_path

    def initialize(tmp_path)
      self.tmp_path = tmp_path
    end

    def start!(opts = {})
      run!("start", { ontop: opts[:ontop] })
    end

    def stop!
      run!("stop")
    end

    def status!
      run!("status")
    end

    def run!(cmd, opts = {})
      # On darwin, when the running Ruby is not compiled for the running OS
      # @see: https://github.com/BerlinVagrant/vagrant-dns/issues/72
      use_issue_72_workround = RUBY_PLATFORM.match?(/darwin/) && !RUBY_PLATFORM.end_with?(`uname -r`[0, 2])

      if cmd == "start" && use_issue_72_workround
        require_relative "./server"
      end

      Daemons.run_proc("vagrant-dns", run_options(cmd, opts)) do
        unless use_issue_72_workround
          require_relative "./server"
        end

        VagrantDNS::Server.new(
          Registry.new(tmp_path),
          listen: VagrantDNS::Config.listen,
          ttl: VagrantDNS::Config.ttl,
          passthrough: VagrantDNS::Config.passthrough,
          resolver: VagrantDNS::Config.passthrough_resolver
        ).run
      end
    end

    def restart!(start_opts = {})
      stop!
      start!(start_opts)
    end

    def show_config
      registry = Registry.open(tmp_path)
      return unless registry

      config = registry.to_hash
      if config.any?
        config.each do |pattern, ip|
          puts format("%s => %s", pattern.inspect, ip)
        end
      else
        puts "Pattern configuration missing or empty."
      end
    end

    def show_tld_config
      tld_registry = VagrantDNS::TldRegistry.open(tmp_path)
      return unless tld_registry

      tlds = tld_registry.transaction { |store| store.fetch("tlds", []) }
      if !tlds || tlds.empty?
        puts "No TLDs configured."
      else
        puts tlds
      end
    end

    private def run_options(cmd, extra = {})
      daemon_dir = File.join(tmp_path, "daemon")
      {
        ARGV: [cmd],
        dir_mode: :normal,
        dir: daemon_dir,
        log_output: true,
        log_dir: daemon_dir,
        **extra
      }
    end
  end
end
