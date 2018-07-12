require 'logger'

module VagrantDNS
  class Config < Vagrant.plugin(2, :config)
    class << self
      attr_accessor :listen, :logger, :auto_run, :check_public_suffix

      def listen
        @listen ||= [[:udp, "127.0.0.1", 5300]]
      end

      def auto_run
        return true if @auto_run.nil?
        @auto_run
      end

      def check_public_suffix
        return { level: "warn", allow_private_domains: false } if @check_public_suffix.nil?
        @check_public_suffix
      end

      def validate_tlds(vm)
        return [true, nil] unless check_public_suffix

        require "public_suffix"

        list = PublicSuffix::List.parse(
          File.read(PublicSuffix::List::DEFAULT_LIST_PATH),
          private_domains: !check_public_suffix[:allow_private_domains]
        )

        failed_tlds = vm.config.dns.tlds.select { |tld| list.find(tld, default: false) }

        err = if failed_tlds.any?
          "tlds include a public suffix: #{failed_tlds.join(', ')}"
        end

        if err && check_public_suffix[:level] == "error"
          [false, err]
        elsif err
          [true, err]
        else
          [true, nil]
        end
      end
    end

    attr_accessor :records
    attr_reader :tlds, :patterns

    def pattern=(pattern)
      @patterns = (pattern ? Array(pattern) : pattern)
    end
    alias_method :patterns=, :pattern=

    def tld=(tld)
      @tlds = Array(tld)
    end

    def tlds
      @tlds ||= []
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :patterns => patterns,
        :records => records,
        :tlds => tlds
      }
    end

    def validate(machine)
      errors = _detected_errors

      errors = validate_check_public_suffix(errors, machine)

      { "vagrant_dns" => errors }
    end

    def validate_check_public_suffix(errors, machine)
      valid, err = self.class.validate_tlds(machine)

      if !valid
        errors << err
      elsif err
        machine.ui.warn(err)
      end

      errors
    end
  end
end

