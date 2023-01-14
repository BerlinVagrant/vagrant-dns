require 'yaml/store'
require 'forwardable'

module VagrantDNS
  module Store
    module InstanceMethods
      # This method is only valid in a #transaction and it cannot be read-only. It will raise PStore::Error if called at any other time.
      def [](name)
        name = name.source if name.respond_to? :source
        @store[name]
      end

      # This method is only valid in a #transaction and it cannot be read-only. It will raise PStore::Error if called at any other time.
      def []=(name, value)
        name = name.source if name.respond_to? :source
        @store[name] = value
      end

      def delete(name)
        name = name.source if name.respond_to? :source
        @store.delete(name)
      end

      # This method is only valid in a #transaction and it cannot be read-only. It will raise PStore::Error if called at any other time.
      def root?(name)
        name = name.source if name.respond_to? :source
        @store.root?(name)
      end
      alias_method :key?, :root?

      # This method is only valid in a #transaction and it cannot be read-only. It will raise PStore::Error if called at any other time.
      def roots
        @store.roots.map { |name| Regexp.new(name) }
      end
      alias_method :keys, :roots

      # This method is only valid in a #transaction and it cannot be read-only. It will raise PStore::Error if called at any other time.
      def any?
        @store.roots.any?
      end

      def to_hash
        @store.transaction(true) do
          @store.roots.each_with_object({}) do |name, a|
            a[Regexp.new(name)] = @store[name]
          end
        end
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        extend Forwardable
        def_delegators :@store, :transaction, :abort, :commit
        include InstanceMethods
      end
    end
  end
end
