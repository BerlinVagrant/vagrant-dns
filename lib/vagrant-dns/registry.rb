module VagrantDNS
  # This is the dns pattern registry (aka "config")
  # It basically delegates everything to a YAML::Store but handles the conversion
  # of Regexp dns-patterns into YAML string keys and reverse.
  class Registry
    include VagrantDNS::Store

    NAME = "config"

    def initialize(tmp_path)
      @store = YAML::Store.new(File.join(tmp_path, NAME), true)
    end

    # @return [VagrantDNS::Registry,nil] Eitehr an instance or +nil+ if cofig file does not exist.
    def self.open(tmp_path)
      new(tmp_path) if File.exist?(File.join(tmp_path, NAME))
    end
  end
end
