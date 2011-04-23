#require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'fileutils'
require 'rake/rdoctask'
require 'rake/testtask'
require './lib/bitsa'

Dir['tasks/**/*.rake'].each { |t| load t }
