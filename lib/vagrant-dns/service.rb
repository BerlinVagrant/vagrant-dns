require 'daemons'


module VagrantDNS
  class Service
    attr_accessor :tmp_path, :options
    
    def initialize(tmp_path)
      self.tmp_path = tmp_path
    end

    def start!
      run!("start")
    end

    def stop!
      run!("stop")
    end

    def run!(action)
      if privileged_port? and Process.uid > 0
        system(*(['sudo'] + VagrantDNS::Command.executable + ["--#{action}"]))
      else
        run_options = {:ARGV => [action]}.merge(runopts)
        run_daemon!(run_options)
      end
    end

    def run_daemon!(options)
      Daemons.run_proc("vagrant-dns", options) do
        require 'rubydns'
        require 'rubydns/system'

        registry = YAML.load(File.read(config_file))
        std_resolver = RubyDNS::Resolver.new(RubyDNS::System::nameservers)

        RubyDNS::run_server(:listen => VagrantDNS::Config.listen) do
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

    def restart!
      stop!
      start!
    end
    
    def runopts
      {:dir_mode => :normal, 
       :dir => File.join(tmp_path, "daemon"),
       :log_output => true,
       :log_dir => File.join(tmp_path, "daemon")}
    end
    
    def config_file
      File.join(tmp_path, "config")
    end

    def privileged_port?
      privileged_servers = VagrantDNS::Config.listen.select { |server| server.last < 1024 }
      !privileged_servers.empty?
    end
  end
end
