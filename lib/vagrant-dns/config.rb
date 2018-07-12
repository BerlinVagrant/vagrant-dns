require 'logger'

module VagrantDNS
  class Config < Vagrant.plugin(2, :config)
    class << self
      attr_accessor :listen, :logger, :auto_run

      def listen
        @listen ||= [[:udp, "127.0.0.1", 5300]]
      end

      def auto_run
        return true if @auto_run.nil?
        @auto_run
      end
    end

    attr_accessor :records, :tlds, :patterns

    def pattern=(pattern)
      self.patterns = pattern
    end

    def tld=(tld)
      @tlds = Array(tld)
    end

    def tlds
      @tlds ||= []
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :patterns => (patterns ? Array(patterns) : patterns),
        :records => records,
        :tlds => tlds,
      }
    end
  end
end

