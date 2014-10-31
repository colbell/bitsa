require File.dirname(__FILE__) + '/helper'

require 'fakeweb'

require "bitsa/contacts_cache"
require "bitsa/gmail_contacts_loader"

describe Bitsa::GmailContactsLoader do
  context "Bitsa::GmailContactsLoader" do
    before(:each) do
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:post, "https://www.google.com/accounts/ClientLogin",
                           :body => "SID=DQAAAGgA...7Zg8CTN\nLSID=DQAAAGsA...lk8BBbG\nAuth=DQAAAGgA...dk3fA5N")
      FakeWeb.register_uri(:get, "https://www.google.com/m8/feeds/contacts/test/thin?orderby=lastmodified&showdeleted=true&max-results=25&start-index=1",
                           :body => <<eos
<feed gd:etag='W/&quot;AkANQXo7eCp7ImA9WxFTGUo.&quot;' xmlns:gContact='http://schemas.google.com/contact/2008' xmlns:gd='http://schemas.google.com/g/2005' xmlns:batch='http://schemas.google.com/gdata/batch' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns='http://www.w3.org/2005/Atom'>
  <id>
    somebody@example.com
  </id>
  <updated>
    2010-04-11T09:39:50.400Z
  </updated>
  <category term='http://schemas.google.com/contact/2008#contact' scheme='http://schemas.google.com/g/2005#kind'/>
  <title>
    Somebodys's Contacts
  </title>
  <link href='http://www.google.com/' rel='alternate' type='text/html'/>
  <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin' rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml'/>
  <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin' rel='http://schemas.google.com/g/2005#post' type='application/atom+xml'/>
  <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin/batch' rel='http://schemas.google.com/g/2005#batch' type='application/atom+xml'/>
  <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin?max-results=25' rel='self' type='application/atom+xml'/>
  <author>
    <name>
      Somebody
    </name>
    <email>
      somebody@example.com
    </email>
  </author>
  <generator uri='http://www.google.com/m8/feeds' version='1.0'>
    Contacts
  </generator>
  <openSearch:totalResults>
    1
  </openSearch:totalResults>
  <openSearch:startIndex>
    1
  </openSearch:startIndex>
  <openSearch:itemsPerPage>
    25
  </openSearch:itemsPerPage>
  <entry gd:etag='&quot;SHc-fTVSLyp7ImA9WxBaEkwIQAU.&quot;'>
    <id>
      http://www.google.com/m8/feeds/contacts/somebody%40example.com/base/0
    </id>
    <updated>
      2010-03-21T23:05:19.955Z
    </updated>
    <app:edited xmlns:app='http://www.w3.org/2007/app'>
      2010-03-21T23:05:19.955Z
    </app:edited>
    <category term='http://schemas.google.com/contact/2008#contact' scheme='http://schemas.google.com/g/2005#kind'/>
    <title>
      Jpe Bloggs
    </title>
    <link href='http://www.google.com/m8/feeds/photos/media/somebody%40example.com/0' gd:etag='&quot;bwR-YldFbCp7ImBIGHMMbBALQAwWIFMBVVc.&quot;' rel='http://schemas.google.com/contacts/2008/rel#photo' type='image/*'/>
    <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin/0' rel='self' type='application/atom+xml'/>
    <link href='http://www.google.com/m8/feeds/contacts/somebody%40example.com/thin/0' rel='edit' type='application/atom+xml'/>
    <gd:email address='jbloggs@example.com' rel='http://schemas.google.com/g/2005#other' primary='true'/>
    <gd:email address='another@example.com' rel='http://schemas.google.com/g/2005#work'/>
    <gContact:groupMembershipInfo href='http://www.google.com/m8/feeds/groups/somebody%40example.com/base/6' deleted='false'/>
  </entry>
</feed>
eos
                           )
    end

    it "should update cache" do
      cache = double('Bitsa::ContactsCache')
      gcl = Bitsa::GmailContactsLoader.new('test', 'pw')
      expect(cache).to receive(:update).once
      expect(cache).to receive(:source_last_modified=).once
      expect(cache).to receive(:source_last_modified)
      expect(cache).to receive(:save).once
      gcl.update_cache(cache)
    end

  end
end
