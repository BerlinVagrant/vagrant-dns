require "tmpdir"

namespace :acceptance do
  def tmp_dir_path
    @tmp_dir_path ||= ENV["VS_TEMP"] || Dir.mktmpdir('vagrant-dns-spec')
  end

  ARTIFACT_DIR = File.join('test', 'acceptance', 'artifacts')

  TEST_BOXES = {
    # Ubuntu 16.04 https://app.vagrantup.com/ubuntu/boxes/xenial64.json
    # :virtualbox => "https://vagrantcloud.com/ubuntu/boxes/xenial64/versions/20180511.0.0/providers/virtualbox.box"
    # Ubuntu 18.04 https://app.vagrantup.com/ubuntu/boxes/bionic64.json
    :virtualbox => "https://vagrantcloud.com/ubuntu/boxes/bionic64/versions/20180709.0.0/providers/virtualbox.box"
  }

  TEST_BOXES.each do |provider, box_url|
    # Declare file download tasks
    directory ARTIFACT_DIR

    file File.join(ARTIFACT_DIR, "#{provider}.box") => ARTIFACT_DIR do |path|
      puts 'Downloading: ' + box_url
      Kernel.system 'curl', '-L', '-o', path.to_s, box_url
    end

    desc "Run acceptance tests for #{provider}"
    task provider => :"setup:#{provider}" do |task|
      box_path = File.expand_path(File.join('..', '..', ARTIFACT_DIR, "#{provider}.box"), __FILE__)
      puts "TMPDIR: #{tmp_dir_path}"
      Kernel.system(
        {
          "VS_PROVIDER" => provider.to_s,
          "VS_BOX_PATH" => box_path,
          "TMPDIR" => tmp_dir_path
        },
        "bundle", "exec", "vagrant-spec", "test"
      )
    end

    desc "downloads test boxes and other artifacts for #{provider}"
    task :"setup:#{provider}" => File.join(ARTIFACT_DIR, "#{provider}.box")
  end
end
