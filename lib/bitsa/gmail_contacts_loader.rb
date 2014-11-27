# Loads Contacts from Gmail into a <tt>ContactsCache</tt> object.
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

require "gdata"

module Bitsa #:nodoc:

  # Loads Contacts from Gmail into a <tt>ContactsCache</tt> object.
  class GmailContactsLoader

    # Ctor specifying the Gmail (or Google Apps) user name and
    # password and optionally the number of records to retrieve in
    # each chunk.
    def initialize(user, pw, fetch_size = 25)
      @user = user
      @pw = pw
      @fetch_size = fetch_size
    end

    # Refresh the passsed <tt>ContactsCache</tt> with the latest contact
    # changes/deletions from Gmail.
    def update_cache(cache)
      client = GData::Client::Contacts.new
      client.clientlogin(@user, @pw)

      idx = 1
      until load_chunk(client, idx, cache) < @fetch_size
        idx += @fetch_size
      end
      cache.source_last_modified = DateTime.now.to_s
      cache.save
    end

    private

    def load_chunk(client, idx, cache)
      last_modified = nil
      url = generate_loader_url(idx, cache)

      feed = client.get(url).to_xml
      feed.elements.each('entry') do |entry|
        name = entry.elements['title'].text
        name ||= ""
        gmail_id = entry.elements['id'].text
        deleted = entry.elements['gd:deleted'] ? true : false
        if deleted
          cache.delete(gmail_id)
        else
          addresses = []
          entry.each_element('gd:email') do | addr |
            addresses << addr.attributes['address']
          end
          cache.update(gmail_id, name, addresses)
        end
        last_modified = entry.elements['updated'].text
      end
      feed.elements.count
    end

    def generate_loader_url(idx, cache)
      url = "https://www.google.com/m8/feeds/contacts/#{@user}/thin"
      url += "?orderby=lastmodified"
      url += "&showdeleted=true"
      url += "&max-results=#{@fetch_size}"
      url += "&start-index=#{idx}"
      url += "&updated-min=#{CGI.escape(cache.source_last_modified)}" if cache.source_last_modified
      url
    end
  end
end
