require 'pathname'
require "vagrant-spec/acceptance"

Vagrant::Spec::Acceptance.configure do |c|
  acceptance_dir = Pathname.new File.expand_path("../test/acceptance", __FILE__)

  c.component_paths = [acceptance_dir.to_s]
  c.skeleton_paths = [(acceptance_dir + 'skeletons').to_s]

  c.provider ENV['VS_PROVIDER'], box: ENV['VS_BOX_PATH'], skeleton_path: c.skeleton_paths

  # there seems no other way to set additional environment variables
  # see: https://github.com/mitchellh/vagrant-spec/pull/17
  c.instance_variable_set(:@env, c.env.merge('VBOX_USER_HOME' => "{{homedir}}"))
end
