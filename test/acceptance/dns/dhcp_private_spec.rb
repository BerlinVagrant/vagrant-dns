shared_examples 'provider/dns_dhcp_private' do |provider, options|

  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file #{options[:box]} must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'
  let(:tmp_path) { environment.instance_variable_get(:@homedir) }

  let(:tld)    { 'spec' }
  let(:name)   { 'dhcp-private.testbox.spec' }

  before do
    ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
    environment.skeleton('dns_dhcp_private')
  end

  describe 'installation' do
    it 'creates and removes resolver link with logged warning that no IP could be found' do
      result = assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      expect(result.stdout).to include("[vagrant-dns] Could not find any static network IP. No patterns will be configured.")

      assert_execute('sudo', 'test', '-f', "/etc/resolver/#{tld}")
      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
      assert_execute('sudo', 'test', '!', '-f', "/etc/resolver/#{tld}")
    end

    it 'skips creating config file' do
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      assert_execute('sudo', 'test', '!', '-f', "#{tmp_path}/tmp/dns/config")
      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
    end
  end

  describe 'running' do
    before do
      assert_execute('vagrant', 'box', 'add', 'box', options[:box])
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      assert_execute('vagrant', 'up', "--provider=#{provider}")
    end

    after do
      # Ensure any VMs that survived tests are cleaned up.
      execute('vagrant', 'destroy', '--force', log: false)
      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
    end

    it 'auto-starts the DNS daemon' do
      assert_execute('pgrep', '-lf', 'vagrant-dns')
    end

    it 'registered as a resolver' do
      # the output of `scutil` changes it's format over MacOS versions a bit
      expected_output = Regexp.new(<<-TXT.gsub(/^\s*/, ''), Regexp::MULTILINE)
        \\s*domain\\s*: #{tld}
        \\s*nameserver\\[0\\]\\s*: 127.0.0.1
        \\s*port\\s*: 5333
        \\s*flags\\s*: Request A records, Request AAAA records
        \\s*reach\\s*: Reachable,\\s?Local Address(, Directly Reachable Address)?
      TXT

      result = assert_execute('scutil', '--dns')
      expect(result.stdout).to match(expected_output)
    end

    it 'does not respond to host-names' do
      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "#{name}")
      expect(result.stdout).to be_empty
    end
  end
end
