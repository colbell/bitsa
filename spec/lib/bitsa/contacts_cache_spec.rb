require 'fileutils'
require 'tempfile'
require 'yaml'

require 'helper'

require 'bitsa/contacts_cache'

URL_START = 'http://www.google.com/m8/feeds/contacts/'

def create_empty_temp_file
  tmp_file = Tempfile.open('cache')
  File.open(tmp_file.path, 'w') do |f|
    f.write('')
  end
  tmp_file
end

def read_test_data
  # 4 users, 5 email addresses
  YAML.load_file('spec/data/bitsa_cache.yml')[1].values.flatten(1).sort
end

def create_cache(last_modified = nil, lifespan_days = 1)
  source_last_modified, addresses = YAML.load_file('spec/data/bitsa_cache.yml')
  source_last_modified = last_modified.to_s if last_modified

  tmp_file = Tempfile.open('cache')
  File.open(tmp_file.path, 'w') do |f|
    f.write(YAML.dump([source_last_modified, addresses]))
  end
  [Bitsa::ContactsCache.new(tmp_file.path, lifespan_days), tmp_file]
end

RSpec.shared_examples_for 'an empty cache' do |c|
  specify { expect(c).not_to be_nil }
  context :size do
    specify { expect(c.size).to eq(0) }
  end
  context 'last modified date' do
    specify { expect(c.source_last_modified).to be_nil }
  end
  context :stale do
    specify { expect(c.stale?).to be_truthy }
  end
end

RSpec.shared_examples 'a full resultset' do |results|
  specify 'should return all entries' do
    expect(results.size).to eq(5)
    expect(results.flatten(0).sort).to eq(read_test_data)
  end
end

describe Bitsa::ContactsCache do
  context 'empty cache file' do
    cache = Bitsa::ContactsCache.new(create_empty_temp_file.path, 1)
    it_behaves_like 'an empty cache', cache
  end

  context 'cache file does not exist' do
    cache = Bitsa::ContactsCache.new('/tmp/idonotexististhatoky', 1)
    it_behaves_like 'an empty cache', cache
  end

  context 'user not authorised to read cache file' do
    let(:tmp_file) do
      tmp_file = create_empty_temp_file
      FileUtils.chmod(0222, tmp_file.path)
      tmp_file
    end

    specify do
      expect do
        Bitsa::ContactsCache.new(tmp_file.path, 1)
      end.to raise_error(Errno::EACCES)
    end
  end

  context 'last updated today and lifespan is 1 day' do
    context :stale do
      specify do
        expect(create_cache(DateTime.now, 1)[0].stale?).to be_falsey
      end
    end
  end

  context 'last updated yesterday and lifespan is 1 day' do
    context :stale do
      specify do
        expect(create_cache(DateTime.now - 1, 1)[0].stale?).to be_truthy
      end
    end
  end

  context 'last updated yesterday and lifespan is 2 days' do
    context :stale do
      specify do
        expect(create_cache(DateTime.now - 1, 2)[0].stale?).to be_falsey
      end
    end
  end

  context 'last updated 3 days ago and lifespan is 0 days' do
    context :stale do
      specify do
        expect(create_cache(DateTime.now - 3, 0)[0].stale?).to be_falsey
      end
    end
  end

  context 'last updated 3 days ago and lifespan is -1 days' do
    context :stale do
      specify do
        expect(create_cache(DateTime.now - 3, -1)[0].stale?).to be_falsey
      end
    end
  end

  context 'after clearing the cache' do
    before(:each) do
      expect(cache.size).to be >= 1
      expect(cache.empty?).to be false
      cache.clear!
    end
    let(:cache) { create_cache[0] }

    context :size do
      specify { expect(cache.size).to eq(0) }
    end

    context 'empty?' do
      specify { expect(cache.empty?).to be true }
    end
  end

  context 'searching the test data' do
    specify 'should have read the correct number of contacts' do
      expect(create_cache[0].size).to eq(4)
    end

    context 'with an empty string' do
      it_behaves_like 'a full resultset', create_cache[0].search('')
    end

    context 'with a nil string' do
      it_behaves_like 'a full resultset', create_cache[0].search(nil)
    end

    context 'searching by start of email address' do
      context 'returning a single result' do
        let(:expected) { [['test1@example.com', 'My Tester']] }

        specify do
          expect(create_cache[0].search('test1')).to match_array expected
        end
      end

      context 'returning multiple results' do
        let(:expected) do
          [['john_smith@here.org', ''],
           ['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']]
        end

        specify { expect(create_cache[0].search('jo')).to match_array expected }
      end
    end

    context 'searching by end of email address' do
      let(:expected) { [['john_smith@here.org', '']] }

      specify { expect(create_cache[0].search('org')).to match_array expected }
    end

    context 'searching by middle of email address' do
      let(:expected)  { [['john_smith@here.org', '']] }

      specify { expect(create_cache[0].search('n_s')).to match_array expected }
    end

    context 'searching email using a different case to the actual data' do
      let(:expected)  { [['john_smith@here.org', '']] }

      specify do
        expect(create_cache[0].search('N_sMI')).to match_array expected
      end
    end

    context 'searching by start of name' do
      let(:expected) { [['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']] }

      specify do
        expect(create_cache[0].search('Joan Blo')).to match_array expected
      end
    end

    context 'searching by end of name' do
      let(:expected) { [['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']] }

      specify do
        expect(create_cache[0].search('ggshere')).to match_array expected
      end
    end

    context 'searching by middle of name' do
      let(:expected) { [['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']] }

      specify { expect(create_cache[0].search('n Bl')).to match_array expected }
    end

    context 'searching name using a different case to the actual data' do
      let(:expected) { [['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']] }

      specify { expect(create_cache[0].search('N BL')).to match_array expected }
    end

    context 'search with no results' do
      context :size do
        specify do
          expect(create_cache[0].search('nothing is here').size).to eq(0)
        end
      end
    end

    context 'search on one contact with two email addresses' do
      let(:expected) do
        [['email2@somewhere.com', 'Mr Multiple'],
         ['email1@somewhere.com', 'Mr Multiple']]
      end

      specify do
        expect(create_cache[0].search('multip')).to match_array expected
      end
    end

    context 'searching a contact with multiple email addresses' do
      let(:expected) { [['email1@somewhere.com', 'Mr Multiple']] }

      specify do
        expect(create_cache[0].search('email1')).to match_array expected
      end
    end

    context 'find by ID' do
      let(:id) { URL_START + 'person%40example.org/base/685e301a549c176e' }
      let(:expected) do
        [['email1@somewhere.com', 'Mr Multiple'],
         ['email2@somewhere.com', 'Mr Multiple']]
      end

      specify { expect(create_cache[0].get(id)).to match_array expected }
    end

    context 'find by a non-existent ID' do
      let(:id) { URL_START + 'person%40example.org/base/4783783783' }

      specify { expect(create_cache[0].get(id)).to be_nil }
    end
  end

  context 'updating the test data' do
    let(:cache) { create_cache[0] }
    let(:id) { URL_START + 'person%40example.org/base/637e301a549c176e' }

    specify 'should change the data' do
      expect(cache.get(id)).to match_array [['Joan.bloggs@somewhere.com.au',
                                             'Joan Bloggshere']]
      cache.update(id, 'Tammy Smith', ['tammy5@example.com'])
      expect(cache.get(id)).to match_array [['tammy5@example.com',
                                             'Tammy Smith']]
    end
  end

  context 'updating with two email addresses' do
    let(:cache) { create_cache[0] }
    let(:id) { URL_START + 'person%40example.org/base/637e301a549c176e' }

    specify 'should update the data' do
      expected = [['Joan.bloggs@somewhere.com.au', 'Joan Bloggshere']]
      expect(cache.get(id)).to match_array expected

      cache.update(id, 'Tammy Smith',
                   ['tammy5@example.com', 'smithtammy@exampel.org'])

      expected = [['smithtammy@exampel.org', 'Tammy Smith'],
                  ['tammy5@example.com', 'Tammy Smith']]
      expect(cache.get(id)).to match_array expected
    end
  end

  context 'deleting a non-existent entry' do
    let(:cache) { create_cache[0] }

    specify 'should return nil' do
      expect(cache.delete('NONEXISTENT')).to be_nil
    end

    specify do
      expect do
        cache.delete('NONEXISTENT')
      end.to_not change(cache, :size)
    end
  end

  context 'deleting an existing entry' do
    let(:cache) { create_cache[0] }
    let(:id) { URL_START + "person%40example.org/base/637e301a549c176e" }

    specify { expect { cache.delete(id) }.to change(cache, :size).by(-1) }

    specify 'should return the deleted entry' do
      expect(cache.delete(id)).to match_array [['Joan.bloggs@somewhere.com.au',
                                                'Joan Bloggshere']]
    end

    context 'the cache' do
      specify 'should no longer contain the deleted entry' do
        cache.delete(id)
        expect(cache.get(id)).to be_nil
      end
    end
  end

  context 'saving' do
    let(:data) { create_cache }
    let(:cache) { data[0] }
    let(:cache_file) { data[1] }

    context 'changes to existing contacts' do
      specify do
        id = URL_START + 'person%40example.org/base/637e301a549c176e'
        cache.update(id, 'The Changed Name', ['change1@somewhere.org'])
        cache.save
        new_cache = Bitsa::ContactsCache.new(cache_file.path, 1)
        expected = [['change1@somewhere.org', 'The Changed Name']]
        expect(new_cache.get(id)).to match_array expected
      end
    end

    context 'adding new entries' do
      specify do
        id = 'NONEXISTENT'
        cache.update(id, 'The Changed Name', ['change1@somewhere.org'])
        cache.save
        new_cache = Bitsa::ContactsCache.new(cache_file.path, 1)
        expected = [['change1@somewhere.org', 'The Changed Name']]
        expect(new_cache.get(id)).to match_array expected
      end
    end

    context 'to a file that I have no write rights to' do
      before(:each) { FileUtils.chmod(0444, cache_file.path) }

      specify { expect { cache.save }.to raise_error(Errno::EACCES) }
    end
  end
end
