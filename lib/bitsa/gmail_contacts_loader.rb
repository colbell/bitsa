# Loads Contacts from Gmail into a <tt>ContactsCache</tt> object.
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

require 'gdata'

module Bitsa #:nodoc:
  # Loads Contacts from Gmail into a <tt>ContactsCache</tt> object.
  class GmailContactsLoader
    # Ctor.
    #
    # @param [String] user Login to use to connect to GMail.
    # @param [String] pw Password to use to connect to GMail.
    # @param [Integer] fetch_size Number of records to retrieve at a time.
    def initialize(user, pw, fetch_size = 25)
      @user = user
      @pw = pw
      @fetch_size = fetch_size
    end

    # Refresh the passed <tt>ContactsCache</tt> with the latest contact
    # changes/deletions from Gmail.
    #
    # @param [Bitsa::ContacstCache] cache Cache to be updated from GMail.
    #
    # @return [nil]
    def update_cache(cache)
      client = GData::Client::Contacts.new
      client.clientlogin(@user, @pw)

      # Retrieve changes updating cache until no more changes.
      idx = 1
      orig_last_modified = cache.cache_last_modified
      until load_chunk(client, idx, cache, orig_last_modified) < @fetch_size
        idx += @fetch_size
      end

      # Write cache to disk
      cache.save
    end

    private

    # Load the next chuck of data from GMail into the cache.
    #
    # @param [GData::Client::Contacts] client Connection to GMail.
    # @param [Integer] idx Index of next piece of data to read from
    #                      <tt>client</tt>.
    # @param [Bitsa::ContacstCache] cache Cache to be updated from GMail.
    # @param [Datetime] orig_last_modified Time that <tt>cache</tt> was last
    #                                      modified before we started our update
    #
    # @return [Integer] Number of records read.
    def load_chunk(client, idx, cache, orig_last_modified)
      # last_modified = nil
      url = generate_loader_url(idx, orig_last_modified)

      feed = client.get(url).to_xml
      feed.elements.each('entry') do |entry|
        process_entry(cache, entry)
        # last_modified = entry.elements['updated'].text
      end
      feed.elements.count
    end

    # Process a Gmail contact, updating the cache appropriately.
    #
    # @param [Bitsa::ContacstCache] cache Cache to be updated from GMail.
    # @param [REXML::Element] entry GMail data for a contact.
    def process_entry(cache, entry)
      gmail_id = entry.elements['id'].text
      if entry.elements['gd:deleted']
        cache.delete(gmail_id)
      else
        addrs = []
        entry.each_element('gd:email') { |a| addrs << a.attributes['address'] }
        cache.update(gmail_id, entry.elements['title'].text || '', addrs)
      end
    end

    # Generate the URL to retrieve the next chunk of data from GMail.
    #
    # @param [Integer] idx Index of next piece of data to read from
    #   <tt>client</tt>.
    # @param [Datetime] cache_last_modified modification time of last contact
    #   read from GMail
    def generate_loader_url(idx, cache_last_modified)
      # FIXME: Escape variables
      url = "https://www.google.com/m8/feeds/contacts/#{@user}/thin"
      url += '?orderby=lastmodified'
      url += '&showdeleted=true'
      url += "&max-results=#{@fetch_size}"
      url += "&start-index=#{idx}"
      if cache_last_modified
        url += "&updated-min=#{CGI.escape(cache_last_modified)}"
      end
      url
    end
  end
end
