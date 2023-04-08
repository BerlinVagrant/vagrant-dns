require 'pp'
require 'rubydns'
require 'async/dns/system'

module VagrantDNS
  class Server
    attr_reader :registry, :listen, :ttl, :resolver

    def initialize(registry, listen:, ttl:, resolver:)
      @registry = registry.to_hash
      @listen = listen
      @ttl = ttl

      @resolver = if resolver.nil? || resolver == :system
        RubyDNS::Resolver.new(Async::DNS::System.nameservers)
      elsif !resolver || resolver.empty?
        nil
      else
        RubyDNS::Resolver.new(resolver)
      end
    end

    def run
      # need those clusures for the +RubyDNS::run_server+ block
      registry = self.registry
      resolver = self.resolver
      ttl = self.ttl

      RubyDNS::run_server(listen) do
        # match all known patterns first
        registry.each do |pattern, ip|
          match(pattern, Resolv::DNS::Resource::IN::A) do |transaction, match_data|
            transaction.respond!(ip, ttl: ttl)
          end
        end

        # fail only known patterns for non-A queries
        registry.each do |pattern, ip|
          match(pattern) do |transaction, match_data|
            transaction.fail!(:NotImp)
          end
        end

        if resolver
          otherwise do |transaction|
            transaction.passthrough!(resolver) do |response|
              puts "Passthrough response: #{response.inspect}"
            end
          end
        else
          otherwise do |transaction|
            transaction.fail!(:NXDomain)
          end
        end
      end
    end
  end
end
