module VagrantDNS
  module Installers
    class Linux
      EXEC_STYLES = %i{sudo}
      CONFIG = "vagrant-dns.conf"

      attr_accessor :tmp_path, :install_path, :exec_style

      def initialize(tmp_path, options = {})
        self.tmp_path     = tmp_path
        self.install_path = options.fetch(:install_path, "/etc/systemd/resolved.conf.d")
        self.exec_style   = options.fetch(:exec_style, :sudo)
      end

      def install!
        require 'fileutils'

        src = File.join(tmp_path, "resolver", CONFIG)
        dest = File.join(install_path, CONFIG)

        commands = [
          ['install', '-D', '-m', '0644', '-T', src.shellescape, dest.shellescape],
          ['systemctl', 'reload-or-restart', 'systemd-resolved.service']
        ]

        exec(*commands)
      end

      def uninstall!
        require 'fileutils'

        commands = [
          ['rm', File.join(install_path, CONFIG)]
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
