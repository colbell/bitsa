require "fileutils"
require "tempfile"

require "helper"

require "bitsa/contacts_cache"

describe Bitsa::ContactsCache do
  context "cache" do
    it "should build successfully if cache file empty" do
      tmp_file = create_empty_temp_file
      cache = Bitsa::ContactsCache.new(tmp_file.path, 1)
      should_be_an_empty_cache cache
    end

    it "should build successfully if cache file does not exist" do
      cache = Bitsa::ContactsCache.new("/tmp/idonotexististhatoky", 1)
      should_be_an_empty_cache cache
    end

    it "should fail with exception if user not authorised to read cache file" do
      tmp_file = create_empty_temp_file
      FileUtils.chmod(0222, tmp_file.path)
      lambda { Bitsa::ContactsCache.new(tmp_file.path, 1).should raise_error(Errno::EACCES) }
    end

    it "should not be stale if last updated today" do
      create_cache(DateTime.now, 1)
      @cache.stale?.should_not be_true
    end

    it "should be stale if last updated yesterday and lifespan is 1 day" do
      create_cache(DateTime.now-1, 1)
      @cache.stale?.should be_true
    end

    it "should not be stale if last updated yesterday and lifespan is 2 days" do
      create_cache(DateTime.now-1, 2)
      @cache.stale?.should_not be_true
    end
  end

  context "clearing the cache" do
    before(:each) do
      create_cache
      @cache.should have_at_least(1).entries
      @cache.empty?.should be_false
    end

    it "should leave the cache empty" do
      @cache.clear!
      @cache.size.should == 0
      @cache.empty?.should be_true
    end
  end

  context "searching the test data" do
    # 4 contacts with 5 email addresses
    before(:all) { create_cache }

    it "should have read the correct number of contacts" do
      @cache.size.should == 4
    end

    it "should have the correct entries" do
      @cache.addresses.should == read_test_data
    end

     it "should return all entries if blank searched for" do
      results = @cache.search('')
      results.size.should == 5
      @cache.addresses.should =~ read_test_data
    end

    it "should return all entries if a nill string searched for" do
      results = @cache.search(nil)
      results.size.should == 5
      @cache.addresses.should =~ read_test_data
    end

    it "should find correctly when searching by start of email address" do
      results = @cache.search('test1')
       results.should =~ [["test1@example.com", "My Tester"]]

       results = @cache.search('jo')
       expected = [["john_smith@here.org", ""], ["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
       results.should =~ expected
     end

    it "should find correctly when searching by end of email address" do
      results = @cache.search('org')
      expected = [["john_smith@here.org", ""]]
      results.should =~ expected
    end

    it "should find correctly when searching by middle of email address" do
      results = @cache.search('n_s')
      expected = [["john_smith@here.org", ""]]
      results.should =~ expected
    end

    it "should find correctly when searching by email address irrespective of case" do
      results = @cache.search('N_sMI')
      expected = [["john_smith@here.org", ""]]
      results.should =~ expected
    end

    it "should find correctly when searching by start of name" do
      results = @cache.search('Joan Blo')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected
    end

    it "should find correctly when searching by end of name" do
      results = @cache.search('ggshere')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected
    end

    it "should find correctly when searching by middle of name" do
      results = @cache.search('n Bl')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected
    end

    it "should find correctly when searching by name irrespective of case" do
      results = @cache.search('N BL')
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected
    end

    it "should find no results if nothing to find" do
      results = @cache.search('nothing is here')
      results.size.should == 0
    end

    it "should return all email addresses on a contact with multiple email addresses when matching on name" do
      results = @cache.search('multip')
      expected = [["email2@somewhere.com", "Mr Multiple"], ["email1@somewhere.com", "Mr Multiple"]]
      results.should =~ expected
    end

    it "should return only the matched email address on a contact with multiple email addresses" do
      results = @cache.search('email1')
      expected = [["email1@somewhere.com", "Mr Multiple"]]
      results.should =~ expected
     end

    it "should find by ID correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/685e301a549c176e"
      results = @cache.get(id)
      expected = [["email1@somewhere.com", "Mr Multiple"],
                  ["email2@somewhere.com", "Mr Multiple"]]
      results.should =~ expected
    end

    it "should return nil if finding by a non-existent ID" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/4783783783"
      @cache.get(id).should be_nil
    end
  end

  context "updating the test data" do
    # 4 contacts with 5 email addresses
    before(:each) { create_cache }

    it "should handle update with a single email address correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      results = @cache.get(id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected

      @cache.update(id, "Tammy Smith", ["tammy5@example.com"])
      results = @cache.get(id)
      expected = [["tammy5@example.com", "Tammy Smith"]]
      results.should =~ expected
    end

    it "should handle update with two email addresses correctly" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      results = @cache.get(id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected

      @cache.update(id, "Tammy Smith", ["tammy5@example.com", "smithtammy@exampel.org"])
      results = @cache.get(id)
      expected = [["smithtammy@exampel.org", "Tammy Smith"], ["tammy5@example.com", "Tammy Smith"]]
      results.should =~ expected
    end
  end

  context "deleting a non-existent entry" do
    before(:each) { create_cache }

    it "should no longer contain the deleted entry" do
      @cache.delete("NONEXISTENT")
      @cache.get("NONEXISTENT").should be_nil
    end

    it "should not change the number of entries in the cache" do
      lambda {
        @cache.delete("NONEXISTENT")
      }.should_not change(@cache, :size)
    end

    it "should return nil" do
      @cache.delete("NONEXISTENT").should be_nil
    end
  end

  context "deleting an existing entry" do
    before(:each) do
      create_cache
      @id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
    end

    it "should_change the number of entries by -1" do
      lambda {
        @cache.delete(@id)
      }.should change(@cache, :size).by(-1)
    end

    it "should return the deleted entry" do
      results = @cache.delete(@id)
      expected = [["Joan.bloggs@somewhere.com.au", "Joan Bloggshere"]]
      results.should =~ expected
    end

    it "should no longer contain the deleted entry" do
      @cache.delete(@id)
      @cache.get(@id).should be_nil
    end
  end

  context "saving the test data" do
    before(:each) { create_cache }
    it "should save changes to existing contacts" do
      id = "http://www.google.com/m8/feeds/contacts/person%40example.org/base/637e301a549c176e"
      @cache.update(id, "The Changed Name", ["change1@somewhere.org"])
      @cache.save
      new_cache = Bitsa::ContactsCache.new(@tmp_file.path, 1)
      expected = [["change1@somewhere.org", "The Changed Name"]]
      new_cache.get(id).should =~ expected
    end

    it "should save newly added entries" do
      id = "NONEXISTENT"
      @cache.update(id, "The Changed Name", ["change1@somewhere.org"])
      @cache.save
      new_cache = Bitsa::ContactsCache.new(@tmp_file.path, 1)
      expected = [["change1@somewhere.org", "The Changed Name"]]
      new_cache.get(id).should =~ expected
    end

    context "to a file that I have no write rights to" do
      before(:each) { FileUtils.chmod(0444, @tmp_file.path) }

      it "should throw an exception when I try to write to it" do
        lambda {@cache.save}.should raise_error(Errno::EACCES)
      end

    end
  end

  private

  def create_cache(last_modified = nil, lifespan_days = 1)
    source_last_modified, addresses = YAML::load_file("spec/data/bitsa_cache.yml")
    source_last_modified = last_modified.to_s if last_modified

    @tmp_file = Tempfile.open("cache")
    File.open(@tmp_file.path, "w") do |f|
      f.write(YAML::dump([source_last_modified, addresses]))
    end
    @cache = Bitsa::ContactsCache.new(@tmp_file.path, lifespan_days)
  end

  def create_empty_temp_file
    tmp_file = Tempfile.open("cache")
    File.open(tmp_file.path, "w") do |f|
      f.write('')
    end
    tmp_file
  end

   def should_be_an_empty_cache cache
     cache.should_not be_nil
     cache.size.should == 0
     cache.source_last_modified.should be_nil
     cache.stale?.should be_true
   end

   def read_test_data
     source_last_modified, addresses = YAML::load_file(@tmp_file.path)
     addresses.values
   end

 end
