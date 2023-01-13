require 'fileutils'

module VagrantDNS
  class Configurator
    attr_accessor :vm, :tmp_path

    def initialize(vm, tmp_path)
      @vm = vm
      @tmp_path = tmp_path
    end

    def up!
      return unless validate_tlds
      regenerate_resolvers!
      ensure_deamon_env!
      register_patterns!
    end

    def down!
      unregister_patterns!
    end

    private
      def validate_tlds
        valid, err = VagrantDNS::Config.validate_tlds(vm)
        if !valid
          vm.ui.error(err)
        elsif err
          vm.ui.warn(err)
        end
        valid
      end

      def regenerate_resolvers!
        resolver_folder = self.resolver_folder
        _proto, ip, port = VagrantDNS::Config.listen.first
        tlds = register_tlds!

        resolver_files(ip, port, tlds) do |filename, contents|
          File.write(File.join(resolver_folder, filename), contents)
        end
      end

      def register_tlds!
        add_tlds = dns_options(vm)[:tlds]
        VagrantDNS::TldRegistry.new(tmp_path).transaction do |store|
          store["tlds"] ||= []
          store["tlds"] |= add_tlds
          store["tlds"]
        end
      end

      def register_patterns!
        opts = dns_options(vm)

        patterns = opts[:patterns] || default_patterns(opts)
        if patterns.empty?
         vm.ui.warn '[vagrant-dns] TLD but no host_name given. No patterns will be configured.'
         return
        end

        network = opts[:networks].find do |nw|
          nw.first == :private_network && nw.last[:ip]
        end

        unless network
          network = opts[:networks].find do |nw|
            nw.first == :public_network && nw.last[:ip]
          end
        end

        unless network
          vm.ui.warn '[vagrant-dns] Could not find any static network IP. No patterns will be configured.'
          return
        end

        ip = network.last[:ip]

        registry = Registry.new(tmp_path)
        registry.transaction do
          patterns.each do |pattern|
            registry[pattern] = ip
          end
        end
      end

      def unregister_patterns!
        opts = dns_options(vm)

        patterns = opts[:patterns] || default_patterns(opts)
        if patterns.empty?
          vm.ui.warn '[vagrant-dns] TLD but no host_name given. No patterns will be removed.'
          return
        end

        registry = Registry.new(tmp_path)
        registry.transaction do
          unless registry.any?
            vm.ui.warn '[vagrant-dns] Configuration missing or empty. No patterns will be removed.'
            registry.abort
          end

          patterns.each do |pattern|
            if (ip = registry.delete(pattern))
              vm.ui.info "[vagrant-dns] Removing pattern: #{pattern} for ip: #{ip}"
            else
              vm.ui.info "[vagrant-dns] Pattern: #{pattern} was not in config."
            end
          end
        end
      end

      def dns_options(vm)
        @dns_options ||= vm.config.dns.to_hash.merge!(
          :host_name => vm.config.vm.hostname,
          :networks => vm.config.vm.networks
        )
      end

      def default_patterns(opts)
        if opts[:host_name]
          opts[:tlds].map { |tld| /^.*#{opts[:host_name]}.#{tld}$/ }
        else
          []
        end
      end

      def resolver_files(ip, port, tlds, &block)
        installer_class = VagrantDNS::Installers.resolve
        installer_class.resolver_files(ip, port, tlds, &block)
      end

      def resolver_folder
        File.join(tmp_path, "resolver").tap { |dir| FileUtils.mkdir_p(dir) }
      end

      def ensure_deamon_env!
        FileUtils.mkdir_p(File.join(tmp_path, "daemon"))
      end
  end
end
