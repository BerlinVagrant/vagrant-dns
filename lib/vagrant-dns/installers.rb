module VagrantDNS
  module Installers
    def self.resolve
      if Vagrant::Util::Platform.darwin?
        VagrantDNS::Installers::Mac
      elsif Vagrant::Util::Platform.linux?
        VagrantDNS::Installers::Linux
      else
        raise 'installing and uninstalling is only supported on Linux and macOS at the moment.'
      end
    end
  end
end

require "vagrant-dns/installers/mac"
require "vagrant-dns/installers/linux"
