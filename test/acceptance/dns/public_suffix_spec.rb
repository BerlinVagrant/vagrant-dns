require "pp"
shared_examples 'provider/tld_public_suffix' do |provider, options|

  if !File.file?(options[:box])
    raise ArgumentError,
      "A box file #{options[:box]} must be downloaded for provider: #{provider}. Try: rake acceptance:setup"
  end

  include_context 'acceptance'
  let(:tmp_path) { environment.homedir }

  let(:tld)    { 'com' }
  let(:name)   { 'public.testbox.com' }

  let(:error_message) { "tlds include a public suffix: #{tld}" }

  before do
    ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
    environment.skeleton('tld_public_suffix')

    vagrantfile = environment.workdir.join("Vagrantfile")
    new_conent = File.read(vagrantfile).gsub(/^\s*(#---VagrantDNS::Config.check_public_suffix---#)/, check_public_suffix_line)
    File.write(vagrantfile, new_conent)
  end

  after do
    # ensure we don't mess up our config
    execute("sudo", "rm", "-f", "/etc/resolver/#{tld}", log: false)
  end

  describe "default config warns" do
    let(:check_public_suffix_line) { "" }

    it "validates and prints error" do
      result = execute('vagrant', 'validate')
      expect(result).to exit_with(0)
      expect(result.stderr).to be_empty
    end
  end

  describe "config level 'error'" do
    let(:check_public_suffix_line) do
      <<-RUBY
      VagrantDNS::Config.check_public_suffix = { level: "error" }
      RUBY
    end

    it "fails validation and prints error" do
      result = execute('vagrant', 'validate')
      expect(result).to_not exit_with(0)
      expect(result.stderr).to include(error_message)
    end

    it "will not start the box" do
      assert_execute('vagrant', 'box', 'add', 'box', options[:box])

      result_up = execute('vagrant', 'up', "--provider=#{provider}")
      expect(result_up.stderr).to include(error_message)
      expect(result_up).to_not exit_with(0)

      result_st = execute('vagrant', 'status')
      expect(result_st.stdout).to match(/default\s+not created/)
    end

    it "does not register a resolver" do
      result = execute('vagrant', 'dns', '--install', '--with-sudo')
      expect(result.stderr).to include(error_message)
      expect(execute('sudo', 'test', '-f', "/etc/resolver/#{tld}")).to_not exit_with(0)
    end
  end

  describe "config `false`" do
    let(:check_public_suffix_line) do
      <<-RUBY
      VagrantDNS::Config.check_public_suffix = false
      RUBY
    end

    it "validates and prints error" do
      result = execute('vagrant', 'validate')
      expect(result).to exit_with(0)
      expect(result.stderr).to be_empty
    end
  end
end
