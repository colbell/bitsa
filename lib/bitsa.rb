# Copyright 2010 Colin Bell.
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

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "bitsa/config_file"
require "bitsa/contacts_cache"
require "bitsa/gmail_contacts_loader"
require "bitsa/settings"

module Bitsa

  # Application entry point.
  class BitsaApp

    # Run application.
    def run(global_opts, cmd, search_data)
      settings = Settings.new
      settings.load(ConfigFile.new(global_opts[:config_file]), global_opts)
      cache = ContactsCache.new(settings.cache_file_path, 1)

      if cmd == "reload"
        cache.clear!
      end

      if ["reload", "update"].include?(cmd) || cache.stale?
        loader = GmailContactsLoader.new(settings.login, settings.password)
        loader.update_cache(cache)
      end

      if cmd == "search"
        puts "" # Force first entry to be displayed in mutt
        cache.search(search_data).each {|k,v| puts "#{k}\t#{v}"}
      end
    end
  end

end
