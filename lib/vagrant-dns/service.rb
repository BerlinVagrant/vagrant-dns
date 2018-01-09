require 'daemons'


module VagrantDNS
  class Service
    attr_accessor :tmp_path

    def initialize(tmp_path)
      self.tmp_path = tmp_path
    end

    def start!(opts = {})
      run_options = {
        :ARGV => ["start"],
        :ontop => opts[:ontop]
      }.merge!(runopts)
      run!(run_options)
    end

    def stop!
      run_options = {:ARGV => ["stop"]}.merge(runopts)
      run!(run_options)
    end

    def status!
      run_options = {:ARGV => ["status"]}.merge(runopts)
      run!(run_options)
    end

    def run!(run_options)
      Daemons.run_proc("vagrant-dns", run_options) do
        require 'rubydns'
        require 'async/dns/system'

        registry = YAML.load(File.read(config_file))
        std_resolver = RubyDNS::Resolver.new(Async::DNS::System.nameservers)

        RubyDNS::run_server(VagrantDNS::Config.listen) do
          registry.each do |pattern, ip|
            match(Regexp.new(pattern), Resolv::DNS::Resource::IN::A) do |transaction, match_data|
              transaction.respond!(ip)
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
    end

    def restart!(start_opts = {})
      stop!
      start!(start_opts)
    end

    def runopts
      daemon_dir = File.join(tmp_path, "daemon")
      {
        :dir_mode   => :normal,
        :dir        => daemon_dir,
        :log_output => true,
        :log_dir    => daemon_dir
     }
    end

    def config_file
      File.join(tmp_path, "config")
    end
  end
end
