$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'bitsa/version'

Gem::Specification.new do |s|
  s.name        = 'bitsa'
  s.version     = Bitsa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['GPL-3.0+']
  s.authors     = ['Colin Noel Bell']
  s.email       = ['col@baibell.org']
  s.homepage    = 'https://github.com/colbell/bitsa'
  s.summary     = 'Command line GMail Contacts lookup tool.'
  s.description = <<eos
Allows you to lookup GMail contacts and cache contacts locally
from the command line.
eos
  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 1.9.0'

  s.extra_rdoc_files = ['README.rdoc', 'HISTORY', 'COPYING']
  s.rdoc_options     = ['--main', 'README.rdoc']

  s.add_dependency 'trollop', '2.1.2'

  # Use the fork until the real one works with Ruby 1.9X
  # s.add_dependency 'gdata', '~> 1.1.2'
  s.add_dependency 'gdata_19', '~> 1.1.3'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'fakeweb', '~> 1.3.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'inch'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end

  s.require_path = 'lib'
end
