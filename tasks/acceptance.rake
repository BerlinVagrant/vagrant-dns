namespace :acceptance do
  ARTIFACT_DIR = File.join('test', 'acceptance', 'artifacts')
  TEST_BOXES = {
    :virtualbox => 'http://files.vagrantup.com/precise32.box'
  }

  directory ARTIFACT_DIR
  TEST_BOXES.each do |(provider, box_url)|
    file File.join(ARTIFACT_DIR, "#{provider}.box") => ARTIFACT_DIR do |path|
      puts 'Downloading: ' + box_url
      Kernel.system 'curl', '-L', '-o', path.to_s, box_url
    end
  end

  desc 'downloads test boxes and other artifacts'
  task :setup => TEST_BOXES.map { |(provider, box_url)| File.join(ARTIFACT_DIR, "#{provider}.box") }

  desc 'runs acceptance tests'
  task :run => :setup do
    command = 'vagrant-spec test'
    puts command
    puts
    exec(command)
  end
end
