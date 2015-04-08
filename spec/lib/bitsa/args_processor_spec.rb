require 'helper'
require 'bitsa/args_processor'

RSpec.shared_examples 'a valid set of args' do |ap|
  context :config_file do
    specify { expect(ap.global_opts[:config_file]).to eq('somefile') }
  end
  context :login do
    specify { expect(ap.global_opts[:login]).to eq('someone') }
  end
  context :password do
    specify { expect(ap.global_opts[:password]).to eq('mypassword') }
  end
  context :autocheck do
    specify { expect(ap.global_opts[:auto_check]).to eq(1) }
  end
end

def valid_long_args
  args = []
  args.concat ['--config-file', 'somefile']
  args.concat ['--login', 'someone']
  args.concat ['--password', 'mypassword']
  args.concat ['--auto-check', '1']
  args << 'update'
  args
end

describe Bitsa::CLI do
  let(:ap) { Bitsa::CLI.new }

  it 'should raise SystemExit if an invalid command passed' do
    expect { ap.parse(['unknown']) }.to raise_error(SystemExit)
  end

  it 'should raise SystemExit if nothing passed' do
    expect { ap.parse([]) }.to raise_error(SystemExit)
  end

  context 'passed' do
    [['reload'], ['skel'], %w(search data), ['update']].each do |cmd, data|
      context "#{cmd} command" do
        before { ap.parse([cmd, data]) }
        specify { expect(ap.cmd).to eq(cmd) }
      end
    end
  end

  context 'passing valid long arguments' do
    ap = Bitsa::CLI.new
    ap.parse(valid_long_args)
    it_behaves_like 'a valid set of args', ap
  end

  context 'passing valid short arguments' do
    args = []
    args.concat ['-c', 'somefile']
    args.concat ['-l', 'someone']
    args.concat ['-p', 'mypassword']
    args.concat ['-a', '1']
    args << 'update'

    ap = Bitsa::CLI.new
    ap.parse(args)
    it_behaves_like 'a valid set of args', ap
  end

  context 'Alphabetic --auto-check argument passed' do
    let(:args) { valid_long_args.map { |x| x == '1' ? 'a' : x } }

    specify do
      expect { Bitsa::CLI.new.parse(args) }.to raise_error(SystemExit)
    end
  end

  context 'Zero --auto-check argument passed' do
    let(:ap) { Bitsa::CLI.new }
    before(:each) { ap.parse(valid_long_args.map { |x| x == '1' ? '0' : x }) }

    context 'auto-check' do
      specify { expect(ap.global_opts[:auto_check]).to eq(0) }
    end
  end

  context 'Not passing --auto-check' do
    let(:ap) { Bitsa::CLI.new }
    before(:each) { ap.parse ['update'] }

    context 'auto-check' do
      specify { expect(ap.global_opts[:auto_check]).to be_nil }
    end
  end

  context 'Not passing --config-file' do
    before(:each) { ap.parse ['update'] }
    let(:ap) { Bitsa::CLI.new }

    context 'config_file' do
      specify do
        expect(ap.global_opts[:config_file]).to eq('~/.bitsa_config.yml')
      end
    end
  end

  context 'passing --search with some search data' do
    before(:each) { ap.parse %w(search something) }
    let(:ap) { Bitsa::CLI.new }

    context 'search_data' do
      specify { expect(ap.search_data).to eq 'something' }
    end
  end
end
