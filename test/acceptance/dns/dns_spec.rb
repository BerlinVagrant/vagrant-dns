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
      assert_execute('sudo', 'ls', "/etc/resolver/#{tld}")

      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
      result = execute('sudo', 'ls', "/etc/resolver/#{tld}")
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
      result = assert_execute('scutil', '--dns').stdout.lines
      start  = result.find_index {|l| l =~ /^\s*domain\s*:\s*#{tld}$/} - 1
      offset = result[start..-1].find_index {|l| l == "\n"} - 1

      resolver = result[start..(start + offset)]

      expect(resolver).to include(match /^\s*port\s*:\s*5333$/)
      expect(resolver).to include(match /^\s*flags\s*:\s*Request A records, Request AAAA records$/)
      expect(resolver).to include(match /^\s*port\s*:\s*5333$/)
      expect(resolver).to include(match /\bReachable\b/)
      expect(resolver).to_not include(match /\bNot Reachable\b/i)
      expect(resolver).to include(match /\bReachable\b/)
      expect(resolver).to include(match /\bLocal Address\b/)
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
