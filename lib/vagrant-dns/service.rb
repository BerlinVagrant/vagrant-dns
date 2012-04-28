module VagrantDNS
  class Service
    attr_accessor :dns_options
    
    def initialize(opts)
      self.dns_options = opts
    end

    def start!
      run_options = {:ARGV => ["start"]}
      run!(run_options)
    end

    def stop!
      run_options = {:ARGV => ["stop"]}
      run!(run_options)
    end

    def run!(run_options)
      Daemons.run_proc("dnsserver.rb", run_options) do
        require 'rubydns'

        dns_options = self.dns_options # meh, instance_eval

        RubyDNS::run_server(:listen => VagrantDNS::Config.listen) do
          self.logger = VagrantDNS::Config.logger if VagrantDNS::Config.logger

          dns_options.each do |opts|
            patterns = opts[:patterns] || [/^.*#{opts[:host_name]}.#{opts[:tld]}$/] 

            patterns.each do |pattern|
              network = opts[:networks].first
              ip      = network.last.first

              action  = lambda { |match_data, transaction| transaction.respond!(ip) }

              match(pattern, :A, &action)
            end
          end
        end
      end
    end

    def restart!
      stop
      start
    end
  end
end