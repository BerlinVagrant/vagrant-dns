module VagrantDNS
  class Service
    attr_accessor :tmp_path, :options
    
    def initialize(tmp_path, options = {})
      self.tmp_path = tmp_path
      self.options = options
    end

    def start!
      run_options = {:ARGV => ["start"]}.merge(options).merge(runopts)
      run!(run_options)
    end

    def stop!
      run_options = {:ARGV => ["stop"]}.merge(options).merge(runopts)
      run!(run_options)
    end

    def run!(run_options)
      Daemons.run_proc("vagrant-dns", run_options) do
        require 'rubydns'

        registry = YAML.load(File.read(config_file))

        RubyDNS::run_server(:listen => VagrantDNS::Config.listen) do
          registry.each do |pattern, ip|
            match(Regexp.new(pattern), :A) do |match_data, transaction|
              transaction.respond!(ip)
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
  end
end