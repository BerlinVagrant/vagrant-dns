require 'logger'

module VagrantDNS
  class Config < Vagrant::Config::Base
    class << self
      attr_accessor :listen, :logger, :ipv4only

      def listen
        @listen ||= [[:udp, "127.0.0.1", 5300]]
      end

      def ipv4only
        @ipv4only || @ipv4only.nil?
      end
    end

    attr_accessor :records, :tld, :ipv4only, :patterns

    def pattern=(pattern)
      self.patterns = pattern
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :patterns => (patterns ? Array(patterns) : patterns),
        :records => records,
        :tld => tld,
        :ipv4only => ipv4only
      }
    end
  end
end

