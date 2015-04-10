require 'bundler'
Bundler::GemHelper.install_tasks

require 'fileutils'
require 'rdoc/task'
require 'rake/testtask'
require './lib/bitsa'

Dir['tasks/**/*.rake'].each { |t| load t }

# Make spec the default rake task. This is for travis-ci
require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new
