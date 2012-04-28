require 'logger'

module VagrantDNS
  
  class Config < Vagrant::Config::Base
    class << self
      attr_accessor :listen, :logger
      
      def listen
        @listen ||= [[:udp, "127.0.0.1", 5300]]
      end
    end
    
    attr_accessor :records, :tld
    
    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :records => records,
        :tld => tld
      }
    end
    
  end
end

