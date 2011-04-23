# Loads Contacts from Gmail into a <tt>ContactsCache</tt> object.
#
# Copyright (C) 2010 Colin Noel Bell.
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

    # Number of contacts to retrieve as a single chunk.
    @@FETCH_SIZE = 25

    # Ctor specifying the Gmail (or Google Apps) user name and password.
    def initialize(user, pw) #, lifespan_days)
      @user = user
      @pw = pw
    end

    # Refresh the passsed <tt>ContactsCache</tt> with the latest contact
    # changes/deletions from Gmail.
    def update_cache(cache)
      client = GData::Client::Contacts.new
      client.clientlogin(@user, @pw)

      idx = 1
      until load_chunk(client, idx, cache) < @@FETCH_SIZE
        idx += @@FETCH_SIZE
      end
      cache.source_last_modified = DateTime.now.to_s
      cache.save
    end

    private

    def load_chunk(client, idx, cache)
      last_modified = nil
      url = "http://www.google.com/m8/feeds/contacts/#{@user}/thin"
      url += "?orderby=lastmodified"
      url += "&showdeleted=true"
      url += "&max-results=#{@@FETCH_SIZE}"
      url += "&start-index=#{idx}"
      url += "&updated-min=#{CGI.escape(cache.source_last_modified)}" if cache.source_last_modified
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
  end
end
