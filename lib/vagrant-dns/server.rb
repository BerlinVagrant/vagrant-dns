require 'pp'
require 'rubydns'
require 'async/dns/system'

module VagrantDNS
  class Server
    attr_reader :registry, :listen, :ttl, :resolver, :passthrough

    def initialize(registry, listen:, ttl:, resolver:, passthrough:)
      @registry = registry.to_hash
      @listen = listen
      @ttl = ttl

      @resolver = if resolver.nil? || resolver == :system
        Async::DNS::Resolver.default
      elsif !resolver || resolver.empty?
        nil
      else
        RubyDNS::Resolver.new(resolver)
      end

      if passthrough && !resolver
        puts "[Warning] 'passthrough' config has no effect, sice no passthrough resolver is set."
      end

      @passthrough = !!@resolver && passthrough
    end

    def run
      # need those clusures for the +RubyDNS::run_server+ block
      passthrough = self.passthrough
      registry = self.registry
      resolver = self.resolver
      ttl = self.ttl

      _passthrough = if passthrough
        proc do |transaction|
          transaction.passthrough!(resolver) do |response|
            puts "Passthrough response: #{response.inspect}"
          end
        end
      end

      RubyDNS::run_server(listen) do
        # match all known patterns first
        registry.each do |pattern, ip|
          match(pattern, Resolv::DNS::Resource::IN::A) do |transaction, match_data|
            transaction.respond!(ip, ttl: ttl)
          end
        end

        case passthrough
        when true
          # forward everything
          otherwise(&_passthrough)
        when false
          # fail known patterns for non-A queries as NotImp
          registry.each do |pattern, ip|
            match(pattern) do |transaction, match_data|
              transaction.fail!(:NotImp)
            end
          end

          # unknown pattern end up as NXDomain
          otherwise do |transaction|
            transaction.fail!(:NXDomain)
          end
        when :unknown
          # fail known patterns for non-A queries as NotImp
          registry.each do |pattern, ip|
            match(pattern) do |transaction, match_data|
              transaction.fail!(:NotImp)
            end
          end

          # forward only unknown patterns
          otherwise(&_passthrough)
        end
      end
    end
  end
end
