require "helper"
require "bitsa/args_processor"

RSpec.shared_examples "a_valid_set_of_args" do |ap|
  it "should be a valid set of args" do
    expect(ap.global_opts[:config_file]).to eq("somefile")
    expect(ap.global_opts[:login]).to eq("someone")
    expect(ap.global_opts[:password]).to eq("mypassword")
  end
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
    args = []
    args << "--config-file"
    args << "somefile"
    args << "--login"
    args << "someone"
    args << "--password"
    args << "mypassword"
    args << "update"

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
    args << "update"

    ap = Bitsa::ArgsProcessor.new
    ap.parse(args)
    RSpec.describe @ap do
      it_behaves_like "a_valid_set_of_args", ap
    end
  end

end
