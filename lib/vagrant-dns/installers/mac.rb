module VagrantDNS
  module Installers
    class Mac
      attr_accessor :tmp_path, :install_path

      def initialize(tmp_path, install_path = "/etc/resolver")
        self.tmp_path, self.install_path = tmp_path, install_path
      end

      def install!
        require 'fileutils'

        `sudo mkdir -p #{install_path}`
        registered_resolvers.each do |resolver|
          `sudo ln -sf #{resolver} #{install_path}`
        end
      end

      def uninstall!
        require 'fileutils'

        registered_resolvers.each do |r|
          installed_resolver = File.join(install_path, File.basename(r))
          `sudo rm -rf #{installed_resolver}`
        end
      end

      def registered_resolvers
        Dir[File.join(tmp_path, "resolver", "*")]
      end
    end
  end
end
