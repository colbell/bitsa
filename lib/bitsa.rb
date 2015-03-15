# Copyright 2011-2015 Colin Bell.
#
# This file is part of Bitsa.
#
# Bitsa is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

unless $LOAD_PATH.include?(File.dirname(__FILE__)) ||
       $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
end

require 'bitsa/config_file'
require 'bitsa/contacts_cache'
require 'bitsa/gmail_contacts_loader'
require 'bitsa/settings'

module Bitsa
  # Application entry point.
  class BitsaApp
    # Run application.
    def run(global_opts, cmd, search_data)
      settings = load_settings(global_opts)
      cache = ContactsCache.new(settings.cache_file_path, settings.auto_check)

      generate_skeleton && return if cmd == 'skel'

      cache.clear! if cmd == 'reload'

      if %w(reload, update).include?(cmd) || cache.stale?
        update_cache(cache, settings.login, settings.password)
      end

      search(cache, search_data) if cmd == 'search'
    end

    private

    def load_settings(global_opts)
      settings = Settings.new
      settings.load(ConfigFile.new(global_opts[:config_file]), global_opts)
      settings
    end

    # Write a skeleton configuration to standard output
    def generate_skeleton
      puts <<-EOS
---
:login: myself@gmail.com
:password: mypassword
:cache_file_path: ~/.bitsa_cache.yml
:auto_check: 1
EOS
    end

    # Search the cache for the requested search_data.
    def search(cache, search_data)
      puts '' # Force first entry to be displayed in mutt
      cache.search(search_data).each { |k, v| puts "#{k}\t#{v}" }
    end

    def update_cache(cache, login, password)
      GmailContactsLoader.new(login, password).update_cache(cache)
    end
  end
end
