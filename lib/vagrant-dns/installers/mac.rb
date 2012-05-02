module VagrantDNS
  module Installers
    class Mac
      attr_accessor :tmp_path, :install_path

      def initialize(tmp_path, install_path = "/etc/resolver")
        self.tmp_path, self.install_path = tmp_path, install_path
      end

      def install!
        require 'fileutils'
        FileUtils.mkdir_p('/etc/resolver')

        registered_resolvers.each do |r|
          FileUtils.ln_s(registered_resolvers, "/etc/resolver", :force => true)
        end
      rescue Errno::EACCES => e
        warn "vagrant-dns needs superuser access to manipulate DNS settings"
        raise e
      end

      def uninstall!
        require 'fileutils'

        registered_resolvers.each do |r|
          resolver = File.join("/etc/resolver", File.basename(r))
          FileUtils.rm_f(resolver)
        end
      rescue Errno::EACCES => e
        warn "vagrant-dns needs superuser access to manipulate DNS settings"
        raise e
      end
      
      def registered_resolvers
        Dir[File.join(tmp_path, "resolver", "*")]
      end
    end
  end
end