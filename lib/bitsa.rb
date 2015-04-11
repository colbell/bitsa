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
  #
  # @example run the application
  #   args = Bitsa::CLI.new
  #   args.parse(ARGV)
  #   app = Bitsa::BitsaApp.new
  #   app.run(args.global_opts, args.cmd, args.search_data)
  class BitsaApp
    # Run application.
    #
    # @param global_opts [Hash] Application arguments
    # @param cmd [String] The command requested.
    # @param search_data [String] Data to search for from cmd line.
    #
    # @return [nil] ignored
    def run(global_opts, cmd, search_data)
      settings = load_settings(global_opts)
      process_cmd(cmd, search_data, settings.login, settings.password,
                  ContactsCache.new(settings.cache_file_path,
                                    settings.auto_check))
    end

    private

    # Process a command passed on the command line.
    # @param cmd [String] The command requested.
    # @param search_data [String] Data to search for from cmd line.
    # @param login [String] GMail login.
    # @param password [String] GMail password.
    def process_cmd(cmd, search_data, login, password, cache)
      if cmd == 'skel'
        generate_skeleton
        return
      end

      cache.clear! if cmd == 'reload'

      if %w(reload, update).include?(cmd) || cache.stale?
        update_cache(cache, login, password)
      end

      search(cache, search_data) if cmd == 'search'
    end

    # Load settings, combining arguments from cmd lien and the settings file.
    # @param global_opts [Hash] Application arguments
    # @return [Settings] Object representing the settings for this run of the
    #                    app.
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

    # Search the cache for the requested search_data and write the results to
    # std output.
    # @param cache [ContactsCache] Cache of contacts to be searched.
    # @param search_data [String] Data to search cache for.
    def search(cache, search_data)
      puts '' # Force first entry to be displayed in mutt
      # Write out as EMAIL <TAB> NAME
      cache.search(search_data).each { |k, v| puts "#{k}\t#{v}" }
    end

    # @param cache [ContactsCache] Cache of contacts to be searched.
    # Update cache with any changes from GMail.
    # @param login [String] GMail login.
    # @param password [String] GMail password.
    def update_cache(cache, login, password)
      GmailContactsLoader.new(login, password).update_cache(cache)
    end
  end
end
