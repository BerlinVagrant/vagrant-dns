shared_examples 'provider/dns_static_private' do |provider, options|

  if options[:box] && !File.file?(options[:box])
    raise ArgumentError,
      "A box file #{options[:box]} must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'
  let(:tmp_path) { environment.homedir }

  let(:box_ip) do
    case provider
    when "virtualbox" then '10.10.10.101'
    when "vmware_desktop" then '192.168.134.111'
    end
  end
  let(:tld)    { 'spec' }
  let(:name)   { 'private.testbox.spec' }

  before do
    ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
    environment.skeleton('dns_static_private')
  end

  describe 'installation' do
    it 'creates and removes resolver link' do
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      assert_execute('sudo', 'test', '-f', "/etc/resolver/#{tld}")

      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
      assert_execute('sudo', 'test', '!', '-f', "/etc/resolver/#{tld}")
    end

    it 'creates config file' do
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')

      # writes config file
      result = execute('sudo', 'cat', "#{tmp_path}/tmp/dns/config")
      expect(result).to exit_with(0)
      expect(result.stdout).to include(%Q|"^.*#{name}$": #{box_ip}|)

      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
    end
  end

  describe 'running' do
    before do
      assert_execute('vagrant', 'box', 'add', 'box', options[:box])
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      # skipping "up" here speeds up our specs
      # assert_execute('vagrant', 'up', "--provider=#{provider}")
      assert_execute('vagrant', 'dns', '--start')
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
        \\s*reach\\s*:(?=.*\\bReachable\\b)(?=.*\\bLocal Address\\b).*
      TXT

      result = assert_execute('scutil', '--dns')
      expect(result.stdout).to match(expected_output)
    end

    it 'responds to host-names' do
      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "#{name}")
      expect(result.stdout).to include("ip_address: #{box_ip}")

      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "www.#{name}")
      expect(result.stdout).to include("ip_address: #{box_ip}")

      result = execute('dscacheutil', '-q', 'host', '-a', 'name', "notthere.#{tld}")
      expect(result.stdout).to_not include("ip_address: #{box_ip}")
    end

    it 'vagrant box starts up and is usable' do
      assert_execute('vagrant', 'up', "--provider=#{provider}")
      result = assert_execute('vagrant', 'ssh', '-c', 'whoami')
      expect(result.stdout).to include("vagrant")
    end
  end

  describe 'un-configure' do
    before do
      assert_execute('vagrant', 'box', 'add', 'box', options[:box])
      assert_execute('vagrant', 'dns', '--install', '--with-sudo')
      assert_execute('vagrant', 'dns', '--start')
    end

    after do
      assert_execute('vagrant', 'dns', '--uninstall', '--with-sudo')
    end

    it "removes the host name config on destroy" do
      result = assert_execute('vagrant', 'dns', '--list')
      expect(result.stdout).to include(%Q|/^.*#{name}$/ => #{box_ip}|)

      result = assert_execute('dscacheutil', '-q', 'host', '-a', 'name', "#{name}")
      expect(result.stdout).to include("ip_address: #{box_ip}")

      # don't assert, since it was not created in the first place, but will
      # still trigger the "machine_action_destroy" event
      execute('vagrant', 'destroy', '--force')

      result = assert_execute('vagrant', 'dns', '--list')
      expect(result.stdout).to_not include(name)
      expect(result.stdout).to_not include(box_ip)
      expect(result.stdout).to include("Pattern configuration missing or empty.")
    end
  end
end
