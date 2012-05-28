# Cache of Contacts.
#
# Copyright (C) 2011-2012 Colin Noel Bell.
#
# This file is part of Bitsa.
#
# Bitsa is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "forwardable"

module Bitsa #:nodoc:

  # Cache of Contacts.
  class ContactsCache
    extend Forwardable

    # Number of entries in cache.
    def_delegator :@addresses, :size

    # True if cache is empty.
    def_delegator :@addresses, :empty?

    # Date/Time cache was last updated.
    attr_accessor :source_last_modified

    # Load cache from file system. After <tt>lifespan_days</tt> the cache is considered stale. 
    def initialize(cache_file_path, lifespan_days)
      @cache_file_path = File.expand_path(cache_file_path || "~/.bitsa_cache.yml")
      @lifespan_days = lifespan_days
      @addresses = {}
      @source_source_last_modified = nil
      load_from_file_system
    end

    def stale?
      (@source_last_modified.nil? ||
       (DateTime.parse(@source_last_modified)+@lifespan_days) < DateTime.now)
    end

    # Remove all entries from cache.
    def clear!
      @addresses.clear
      @source_last_modified = nil
    end

    def get(id)
      @addresses[id]
    end

    def search(qry)
      qry ||= ""
      rg = Regexp.new(qry, Regexp::IGNORECASE)

      # Flattens.each_slices to an array with [email1, name1, email2, name2] etc.
      results = @addresses.values.flatten.each_slice(2).find_all do |e, n|
        e.match(rg) || n.match(rg)
      end

      # Sort by case-insensitive email address
      results.sort{|a,b| a[0].downcase <=> b[0].downcase}
    end

    def update(id, name, addresses)
      @addresses[id] = addresses.map { | a | [a, name]}
    end

    def delete(id)
      @addresses.delete(id)
    end

    def save
      File.open(@cache_file_path, "w") do |f|
        f.write(YAML::dump([@source_last_modified, @addresses]))
      end
    end

    private

    def load_from_file_system
      if File.exist?(@cache_file_path)
        @source_last_modified, @addresses = YAML::load_file(@cache_file_path)
        unless @addresses
          @addresses = {}
          @source_last_modified = nil
        end
      end
    end
  end
end
