#!/usr/bin/env rake
require "bundler/gem_tasks"

task_dir = File.expand_path("../tasks", __FILE__)
Dir["#{task_dir}/**/*.rake"].each do |task_file|
  load task_file
end
