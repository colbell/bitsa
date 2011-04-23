require "helper"
require "bitsa/args_processor"

describe Bitsa::ArgsProcessor do
  context "when created" do
    before(:all) { @ap = Bitsa::ArgsProcessor.new }

    it "should recognise the 'update' command" do
      @ap.parse(["update"])
    end

    it "should throw raise SystemExit if an invalid command passed" do
      lambda {@ap.parse(['unknown'])}.should raise_error(SystemExit)
    end

    it "should throw raise SystemExit if nothing passed" do
      lambda {@ap.parse([])}.should raise_error(SystemExit)
    end

    context "and being passed valid commands" do
      [["reload"], ["search", "data"], ["update"]].each do |ar|
        cmd = ar[0]
        it "should recognise the #{cmd} command" do
          @ap.parse(ar)
          @ap.cmd.should == cmd
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

      @ap.parse(args)

      @ap.global_opts[:config_file].should == "somefile"
      @ap.global_opts[:login].should == "someone"
      @ap.global_opts[:password].should == "mypassword"
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

      @ap.parse(args)

      @ap.global_opts[:config_file].should == "somefile"
      @ap.global_opts[:login].should == "someone"
      @ap.global_opts[:password].should == "mypassword"
    end

  end

end
