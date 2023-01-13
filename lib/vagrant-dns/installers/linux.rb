module VagrantDNS
  module Installers
    class Linux
      EXEC_STYLES = %i{sudo}
      RESOLVED_CONFIG = "vagrant-dns.conf"

      attr_accessor :tmp_path, :install_path, :exec_style

      def initialize(tmp_path, options = {})
        self.tmp_path     = tmp_path
        self.install_path = options.fetch(:install_path, "/etc/systemd/resolved.conf.d")
        self.exec_style   = options.fetch(:exec_style, :sudo)
      end

      # Generate the resolved config.
      #
      # @yield [filename, content]
      # @yieldparam filename [String] The filename to use for the resolved config file (relative to +install_path+)
      # @yieldparam content [String] The content for +filename+
      def self.resolver_files(ip, port, tlds)
        contents =
          "# This file is generated by vagrant-dns\n" \
          "[Resolve]\n" \
          "DNS=#{ip}:#{port}\n" \
          "Domains=~#{tlds.join(' ~')}\n"

        yield "vagrant-dns.conf", contents
      end

      def install!
        require 'fileutils'

        src = File.join(tmp_path, "resolver", RESOLVED_CONFIG)
        dest = File.join(install_path, RESOLVED_CONFIG)

        commands = [
          ['install', '-D', '-m', '0644', '-T', src.shellescape, dest.shellescape],
          ['systemctl', 'reload-or-restart', 'systemd-resolved.service']
        ]

        exec(*commands)
      end

      def uninstall!
        commands = [
          ['rm', File.join(install_path, RESOLVED_CONFIG)],
          ['systemctl', 'reload-or-restart', 'systemd-resolved.service']
        ]

        exec(*commands)
      end

      def purge!
        require 'fileutils'
        uninstall!
        FileUtils.rm_r(tmp_path)
      end

      def exec(*commands)
        return if !commands || commands.empty?

        case exec_style
        when :sudo
          commands.each do |c|
            system 'sudo', *c
          end
        else
          raise ArgumentError, "Unsupported execution style: #{exec_style}. Use one of #{EXEC_STYLES.map(&:inspect).join(' ')}"
        end
      end
    end
  end
end
