# Cache of Contacts.
#
# Copyright (C) 2011-2015 Colin Noel Bell.
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

require 'forwardable'

module Bitsa #:nodoc:
  # Cache of Contacts.
  #
  # @example
  #   cache = Bitsa::ContactsCache.new(tmp_file.path, lifespan_days)
  #   cache.search("rob") # => [['robert@example.com]['Robert Brown']]
  class ContactsCache
    extend Forwardable

    # number of contacts
    #
    # @return [Integer]
    #
    # @!method size
    def_delegator :@addresses, :size

    #
    # true if cache is empty else false
    #
    # @return [Boolean]
    #
    # @!method size
    def_delegator :@addresses, :empty?

    # When cache was last modified.
    #
    # @return [Datetime] When cache was last modified.
    #
    # @!attribute [r] cache_last_modified
    attr_reader :cache_last_modified

    # Load cache from file system.
    #
    # @param [String] cache_file_path Path to cache file.
    # @param [Integer] lifespan_days Number of days after which the cache is
    #   considered stale. If nil or 0 then cache is never stale.
    def initialize(cache_file_path, lifespan_days)
      @cache_file_path = File.expand_path(cache_file_path)
      @lifespan_days = lifespan_days
      @addresses = {}
      @source_cache_last_modified = nil
      load_from_file_system
    end

    # Is cache state? true or false
    #
    # @example
    #   stale? # => true
    #
    # @return [Boolean] true if cache stale else false
    def stale?
      @lifespan_days && @lifespan_days > 0 &&
        (@cache_last_modified.nil? ||
         (DateTime.parse(@cache_last_modified) + @lifespan_days) < DateTime.now)
    end

    # Remove all entries from cache.
    #
    # @example
    #   cache.clear
    #   cache.size # => 0
    #
    # @return [nil]
    def clear!
      @addresses.clear
      @cache_last_modified = nil
    end

    # Retrieves name and email addresses for the passed ID.
    #
    # @param [String] id GMail ID for contact
    #
    # @return [[[String, String]]] Array of email addresses and names. Each
    #   element consists of a 2 element array. The first is the email address
    #   and the second is the name
    #
    # @example
    #   cache.get("http://www.google.com/m8/fes/.../base/637e301a549c176e") #=>
    #     [["email1@a.com", "Mr Smith"], ["email2@bsomewhere.com", "Mr Smith"]]
    def get(id)
      @addresses[id]
    end

    # Retrieves name and email addresses that contain the passed string sorted
    # by email adddress
    #
    # @param qry [String] search string
    #
    # @return [[[String, String]]] Array of email addresses and names found.
    #   Each element consists of a 2 element array. The first is the email
    #   address and the second is the name
    #
    # @example
    #   cache.search("smi") #=>
    #     [["e1@acompany.com", "Mr Smith"], ["e2@bsomewhere.com", "Mr Smith"]]
    def search(qry)
      rg = Regexp.new(qry || '', Regexp::IGNORECASE)

      # Flatten to an array with [email1, name1, email2, name2] etc.
      results = @addresses.values.flatten.each_slice(2).find_all do |e, n|
        e.match(rg) || n.match(rg)
      end

      # Sort by case-insensitive email address
      results.sort { |a, b| a[0].downcase <=> b[0].downcase }
    end

    # Update the name and email addresses for the passed GMail ID.
    #
    # @param [String] id ID of contact to be updated
    # @param [String] name new name for contact
    # @param [String[]] addresses array of email addresses
    #
    # @return [[String, String]] Array of email addresses for the <tt>id</tt>
    #                            after update.
    #                            Each element consists of a 2 element array. The
    #                            first is the email address and the second is
    #                            the name
    def update(id, name, addresses)
      @cache_last_modified = DateTime.now.to_s
      @addresses[id] = addresses.map { |a| [a, name] }
    end

    # Delete the contact information for the passed GMail ID.
    #
    # @param [String] id ID of contact to be deleted
    def delete(id)
      @cache_last_modified = DateTime.now.to_s
      @addresses.delete(id)
    end

    # Write out the contacts cache to its cache file.
    #
    # @return [nil]
    def save
      File.open(@cache_file_path, 'w') do |f|
        f.write(YAML.dump([@cache_last_modified, @addresses]))
      end
    end

    private

    # Load contacts cache from the file system.
    def load_from_file_system
      return unless File.exist?(@cache_file_path)
      @cache_last_modified, @addresses = YAML.load_file(@cache_file_path)
      return if @addresses
      @addresses = {}
      @cache_last_modified = nil
    end
  end
end
