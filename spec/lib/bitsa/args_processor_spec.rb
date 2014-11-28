require "helper"
require "bitsa/args_processor"

RSpec.shared_examples "a valid set of args" do |ap|
  context :config_file do
    specify { expect(ap.global_opts[:config_file]).to eq("somefile") }
  end
  context :login do
    specify { expect(ap.global_opts[:login]).to eq("someone") }
  end
  context :password do
    specify { expect(ap.global_opts[:password]).to eq("mypassword") }
  end
  context :autocheck do
    specify { expect(ap.global_opts[:auto_check]).to eq(1) }
  end
end

def valid_long_args
  args = []
  args << "--config-file"
  args << "somefile"
  args << "--login"
  args << "someone"
  args << "--password"
  args << "mypassword"
  args << "--auto-check"
  args << "1"
  args << "update"
  args
end


describe Bitsa::ArgsProcessor do
  context "handling commands" do
    let(:ap) { Bitsa::ArgsProcessor.new }

    it "should recognize the 'update' command" do
      expect { ap.parse(["update"]) }.not_to raise_error
    end

    it "should raise SystemExit if an invalid command passed" do
      expect { ap.parse(["unknown"]) }.to raise_error(SystemExit)
    end

    it "should raise SystemExit if nothing passed" do
      expect { ap.parse([]) }.to raise_error(SystemExit)
    end

    context "and being passed valid commands" do
      [["reload"], ["search", "data"], ["update"]].each do |ar|
        cmd = ar[0]
        it "should recognise the '#{cmd}' command" do
          ap.parse(ar)
          expect(ap.cmd).to eq(cmd)
        end
      end
    end
  end

  context "passing valid long arguments" do
    ap = Bitsa::ArgsProcessor.new
    ap.parse(valid_long_args)
    it_behaves_like "a valid set of args", ap
  end

  context "passing valid short arguments" do
    args = []
    args << "-c"
    args << "somefile"
    args << "-l"
    args << "someone"
    args << "-p"
    args << "mypassword"
    args << "-a"
    args << "1"
    args << "update"

    ap = Bitsa::ArgsProcessor.new
    ap.parse(args)
    it_behaves_like "a valid set of args", ap
  end

  context "Alphabetic --auto-check argument passed" do
    let(:args) { valid_long_args.map { |x| x == "1" ? "a" : x } }

    specify {
      expect { Bitsa::ArgsProcessor.new.parse(args) }.to raise_error(SystemExit)
    }
  end

  context "Zero --auto-check argument passed" do
    let(:ap) { Bitsa::ArgsProcessor.new }
    before(:each) { ap.parse(valid_long_args.map { |x| x == "1" ? "0" : x }) }

    context "auto-check" do
      specify { expect(ap.global_opts[:auto_check]).to eq(0) }
    end
  end

  context "Not passing --auto-check" do
    let(:ap) { Bitsa::ArgsProcessor.new }
    before(:each) { ap.parse ['update']}

    context "auto-check" do
      specify { expect(ap.global_opts[:auto_check]).to be_nil }
    end
  end

  context "Not passing --config-file" do
    before(:each) { ap.parse ['update']}
    let(:ap) { Bitsa::ArgsProcessor.new }

    context "config_file" do
      specify { expect(ap.global_opts[:config_file]).to eq("~/.bitsa_config.yml") }
    end
  end

  context "passing --search with some search data" do
    before(:each) { ap.parse ['search', 'something']}
    let(:ap) { Bitsa::ArgsProcessor.new }

    context "search_data" do
      specify { expect(ap.search_data).to eq "something" }
    end
  end

end
