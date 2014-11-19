require "fileutils"
require "tempfile"
require "yaml"

require "helper"

require "bitsa/contacts_cache"

def create_empty_temp_file
  tmp_file = Tempfile.open("cache")
  File.open(tmp_file.path, "w") do |f|
    f.write('')
  end
  tmp_file
end

def read_test_data
  YAML::load_file("spec/data/bitsa_cache.yml")[1].values.flatten(1).sort
end

def create_cache(last_modified = nil, lifespan_days = 1)
  source_last_modified, addresses = YAML::load_file("spec/data/bitsa_cache.yml")
  source_last_modified = last_modified.to_s if last_modified

  tmp_file = Tempfile.open("cache")
  File.open(tmp_file.path, "w") do |f|
    f.write(YAML::dump([source_last_modified, addresses]))
  end
  [Bitsa::ContactsCache.new(tmp_file.path, lifespan_days), tmp_file]
end

RSpec.shared_examples_for "an_empty_cache" do |c|
  it "should not be nil" do
    expect(c).not_to be_nil
  end
  it "should have a zero size" do
    expect(c.size).to eq(0)
  end
  it "should not have a last modified date" do
    expect(c.source_last_modified).to be_nil
  end
  it "should be stale" do
    expect(c.stale?).to be_truthy
  end
end

RSpec.shared_examples "a_full_resultset" do |results|
  specify "should return all entries" do
    expect(results.size).to eq(5)
    expect(results.flatten(0).sort).to eq(read_test_data)
  end
end

describe Bitsa::ContactsCache do
  context "empty cache file" do
    cache = Bitsa::ContactsCache.new(create_empty_temp_file.path, 1)
    it_behaves_like "an_empty_cache", cache
  end

  context "cache file does not exist" do
    cache = Bitsa::ContactsCache.new("/tmp/idonotexististhatoky", 1)
    it_behaves_like "an_empty_cache", cache
  end

  context "user not authorised to read cache file" do
    specify "should fail with exception" do
      tmp_file = create_empty_temp_file
      FileUtils.chmod(0222, tmp_file.path)
      lambda {
        Bitsa::ContactsCache.new(tmp_file.path, 1).
          should raise_error(Errno::EACCES)
      }
    end
  end

  context "last updated today and lifespan is 1 day" do
    specify "should be stale" do
      expect(create_cache(DateTime.now, 1)[0].stale?).to be_falsey
    end
  end

  context "last updated yesterday and lifespan is 1 day" do
    specify "should be stale" do
      expect(create_cache(DateTime.now-1, 1)[0].stale?).to be_truthy
    end
  end

  context "last updated yesterday and lifespan is 2 days" do
    specify "should not be stale" do
      expect(create_cache(DateTime.now-1, 2)[0].stale?).to be_falsey
    end
  end

  context "last updated 3 days ago and lifespan is 0 days" do
    specify "should not be stale" do
      expect(create_cache(DateTime.now-3, 0)[0].stale?).to be_falsey
    end
  end

  context "last updated 3 days ago and lifespan is -1 days" do
    specify "should not be stale" do
      expect(create_cache(DateTime.now-3, -1)[0].stale?).to be_falsey
    end
  end

  context "after clearing the cache" do
    before(:each) do
      expect(cache.size).to be >= 1
      expect(cache.empty?).to be false
      cache.clear!
    end
    let(:cache) { create_cache[0] }

    specify "size should == 0" do
      expect(cache.size).to eq(0)
    end

    specify "empty? should be true" do
      expect(cache.empty?).to be true
    end
  end

  context "searching the test data" do
    let(:cache) { create_cache[0] }

    specify "should have read the correct number of contacts" do
      expect(create_cache[0].size).to eq(4)
    end

    context "with an empty string" do
      it_behaves_like "a_full_resultset", create_cache[0].search("")
    end

    context "with a nil string" do
      it "should return all entries" do
        results = cache.search(nil)
        expect(results.size).to eq(5)
        expect(results.flatten(0).sort).to eq(read_test_data)
      end
    end

    it "should find correctly when searching by start of email address" do
      results = cache.search('test1')
      expect(results).to match_array [["test1@example.com", "My Tester"]]

      results = cache.search('jo')
      expected = [["john_smith@here.org", ""], ["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by end of email address" do
      results = cache.search('org')
      expected = [["john_smith@here.org", ""]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by middle of email address" do
      results = cache.search('n_s')
      expected = [["john_smith@here.org", ""]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by email address irrespective of case" do
      results = cache.search('N_sMI')
      expected = [["john_smith@here.org", ""]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by start of name" do
      results = cache.search('Joan Blo')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by end of name" do
      results = cache.search('ggshere')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by middle of name" do
      results = cache.search('n Bl')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should find correctly when searching by name irrespective of case" do
      results = cache.search('N BL')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should find no results if nothing to find" do
      results = cache.search('nothing is here')
      expect(results.size).to eq(0)
    end

    it "should return all email addresses on a contact with multiple email addresses when matching on name" do
      results = cache.search('multip')
      expected = [["email2@somewhere.com", "Mr Multiple"], ["email1@somewhere.com", "Mr Multiple"]]
      expect(results).to match_array expected
    end

    it "should return only the matched email address on a contact with multiple email addresses" do
      results = cache.search('email1')
      expected = [["email1@somewhere.com", "Mr Multiple"]]
      expect(results).to match_array expected
    end

    it "should find by ID correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/685e301a549c176e"
      results = cache.get(id)
      expected = [["email1@somewhere.com", "Mr Multiple"],
                  ["email2@somewhere.com", "Mr Multiple"]]
      expect(results).to match_array expected
    end

    it "should return nil if finding by a non-existent ID" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/4783783783"
      expect(cache.get(id)).to be_nil
    end
  end

  context "updating the test data" do
    # 4 contacts with 5 email addresses
    let(:cache) { create_cache[0] }

    it "should handle update with a single email address correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      results = cache.get(id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected

      cache.update(id, "Tammy Smith", ["tammy5@example.com"])
      results = cache.get(id)
      expected = [["tammy5@example.com", "Tammy Smith"]]
      expect(results).to match_array expected
    end

    it "should handle update with two email addresses correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      results = cache.get(id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected

      cache.update(id, "Tammy Smith", ["tammy5@example.com", "smithtammy@exampel.org"])
      results = cache.get(id)
      expected = [["smithtammy@exampel.org", "Tammy Smith"], ["tammy5@example.com", "Tammy Smith"]]
      expect(results).to match_array expected
    end
  end

  context "deleting a non-existent entry" do
    let(:cache) { create_cache[0] }

    it "should not contain the non-existent entry" do
      cache.delete("NONEXISTENT")
      expect(cache.get("NONEXISTENT")).to be_nil
    end

    it "should not change the number of entries in the cache" do
      expect {
        cache.delete("NONEXISTENT")
      }.to_not change(cache, :size)
    end

    it "should return nil" do
      expect(cache.delete("NONEXISTENT")).to be_nil
    end
  end

  context "deleting an existing entry" do
    let(:cache) { create_cache[0] }
    let(:id) { "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e" }

    it "should_change the number of entries by -1" do
      expect { cache.delete(id) }.to change(cache, :size).by(-1)
    end

    it "should return the deleted entry" do
      results = cache.delete(id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      expect(results).to match_array expected
    end

    it "should no longer contain the deleted entry" do
      cache.delete(id)
      expect(cache.get(id)).to be_nil
    end
  end

  context "saving the test data" do
    let(:data) { create_cache }
    let(:cache) { data[0] }
    let(:cache_file) { data[1] }

    it "should save changes to existing contacts" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      cache.update(id, "The Changed Name", ["change1@somewhere.org"])
      cache.save
      new_cache = Bitsa::ContactsCache.new(cache_file.path, 1)
      expected = [["change1@somewhere.org", "The Changed Name"]]
      expect(new_cache.get(id)).to match_array expected
    end

    it "should save newly added entries" do
      id = "NONEXISTENT"
      cache.update(id, "The Changed Name", ["change1@somewhere.org"])
      cache.save
      new_cache = Bitsa::ContactsCache.new(cache_file.path, 1)
      expected = [["change1@somewhere.org", "The Changed Name"]]
      expect(new_cache.get(id)).to match_array expected
    end

    context "to a file that I have no write rights to" do
      before(:each) { FileUtils.chmod(0444, cache_file.path) }

      it "should throw an exception when I try to write to it" do
        expect { cache.save }.to raise_error(Errno::EACCES)
      end

    end
  end

end
