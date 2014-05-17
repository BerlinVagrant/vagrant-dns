shared_examples 'provider/dns' do |provider, options|

  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file #{options[:box]} must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'

  let(:box_ip) { '10.10.10.101' }
  let(:tld)    { 'spec' }
  let(:name)   { 'single.testbox.spec' }

  before do
    ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
    environment.skeleton('dns')
  end

  describe 'installation' do
    it 'creates and removes resolver link' do
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      assert_execute('ls', "/etc/resolver/#{tld}")

      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
      result = execute('ls', "/etc/resolver/#{tld}")
      expect(result).to_not exit_with(0)
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
      assert_execute('vagrant', 'destroy', '--force', log: false)
      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
    end

    it 'auto-starts the DNS daemon' do
      assert_execute('pgrep', '-lf', 'vagrant-dns')
    end

    it 'registered as a resolver' do
      expected_output = <<-TXT
  domain   : #{tld}
  nameserver[0] : 127.0.0.1
  port     : 5333
  flags    : Request A records, Request AAAA records
  reach    : Reachable,Local Address
      TXT

      result = assert_execute('scutil', '--dns')
      expect(result.stdout).to include(expected_output)
    end

    it 'responds to host-names' do
      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "#{name}")
      expect(result.stdout).to include("ip_address: #{box_ip}")

      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "www.#{name}")
      expect(result.stdout).to include("ip_address: #{box_ip}")

      result = execute('dscacheutil', '-q', 'host', '-a', 'name', "notthere.#{tld}")
      expect(result.stdout).to_not include("ip_address: #{box_ip}")
    end
  end

end
