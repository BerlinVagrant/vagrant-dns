module VagrantDNS
  module Installers
    class Mac
      attr_accessor :tmp_path, :install_path

      def initialize(tmp_path, install_path = "/etc/resolver")
        self.tmp_path, self.install_path = tmp_path, install_path
      end

      def install!
        require 'fileutils'

        command = "mkdir -p #{install_path}\n"
        registered_resolvers.each do |resolver|
          command += "ln -sf #{resolver} #{install_path}\n"
        end
        `osascript -e 'do shell script \"#{command}\" with administrator privileges'`
      end

      def uninstall!
        require 'fileutils'

        command = ""
        registered_resolvers.each do |r|
          installed_resolver = File.join(install_path, File.basename(r))
          command += "rm -rf #{installed_resolver}\n"
        end
        `osascript -e 'do shell script \"#{command}\" with administrator privileges'`
      end

      def registered_resolvers
        Dir[File.join(tmp_path, "resolver", "*")]
      end
    end
  end
end
