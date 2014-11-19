require "helper"
require "bitsa/args_processor"

RSpec.shared_examples "a_valid_set_of_args" do |ap|
  it "should be a valid set of args" do
    expect(ap.global_opts[:config_file]).to eq("somefile")
    expect(ap.global_opts[:login]).to eq("someone")
    expect(ap.global_opts[:password]).to eq("mypassword")
    expect(ap.global_opts[:auto_check]).to eq(1)
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
      ap.parse(["update"])
    end

    it "should raise SystemExit if an invalid command passed" do
      expect { ap.parse(["unknown"]) }.to raise_error(SystemExit)
    end

    it "should throw raise SystemExit if nothing passed" do
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

  it "should recognise valid long arguments" do
    args = valid_long_args

    ap = Bitsa::ArgsProcessor.new
    ap.parse(args)
    RSpec.describe @ap do
      it_behaves_like "a_valid_set_of_args", ap
    end
  end

  it "should recognise valid short arguments" do
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
    RSpec.describe @ap do
      it_behaves_like "a_valid_set_of_args", ap
    end
  end

  context "Alphabetic --auto-check argument passed" do
    let(:args) { valid_long_args.map { |x| x == "1" ? "a" : x } }
    it "should raise SystemError" do
      expect { Bitsa::ArgsProcessor.new.parse(args) }.to raise_error(SystemExit)
    end
  end

  context "Zero --auto-check argument passed" do
    let(:args) { valid_long_args.map { |x| x == "1" ? "0" : x } }
    let(:ap) { Bitsa::ArgsProcessor.new }
    it "should pass the auto-check argument to the globals" do
      ap.parse(args)
      expect(ap.global_opts[:auto_check]).to eq(0)
    end
  end

  context "Not passing --auto-check" do
    before(:each) { ap.parse ['update']}
    let(:ap) { Bitsa::ArgsProcessor.new }
    specify "should default to 1" do
      expect(ap.global_opts[:auto_check]).to eq(1)
    end
  end

  context "Not passing --config-file" do
    before(:each) { ap.parse ['update']}
    let(:ap) { Bitsa::ArgsProcessor.new }
    specify "should default to '~/.bitsa_config.yml'" do
      expect(ap.global_opts[:config_file]).to eq("~/.bitsa_config.yml")
    end
  end

end
