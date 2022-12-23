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

    SERVER = Proc.new do |tmp_path|
      require 'rubydns'
      require 'async/dns/system'

      registry = Registry.new(tmp_path).to_hash
      std_resolver = RubyDNS::Resolver.new(Async::DNS::System.nameservers)
      ttl = VagrantDNS::Config.ttl

      RubyDNS::run_server(VagrantDNS::Config.listen) do
        registry.each do |pattern, ip|
          match(pattern, Resolv::DNS::Resource::IN::A) do |transaction, match_data|
            transaction.respond!(ip, ttl: ttl)
          end
        end

        otherwise do |transaction|
          transaction.passthrough!(std_resolver) do |reply, reply_name|
            puts reply
            puts reply_name
          end
        end
      end
    end

    def run!(cmd, opts = {})
      Daemons.run_proc("vagrant-dns", run_options(cmd, opts)) do
        SERVER.call(tmp_path)
      end
    end

    def restart!(start_opts = {})
      stop!
      start!(start_opts)
    end

    def show_config
      registry = Registry.new(tmp_path).to_hash

      if registry.any?
        registry.each do |pattern, ip|
          puts format("%s => %s", pattern.inspect, ip)
        end
      else
        puts "Configuration missing or empty."
      end
    end

    private

    def run_options(cmd, extra = {})
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
