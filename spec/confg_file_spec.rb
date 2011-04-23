require "helper"
require "bitsa/config_file"

describe Bitsa::ConfigFile do
  context "An existing configuration file" do
    before(:all) { @config = Bitsa::ConfigFile.new("spec/data/config.yml") }
     it "should read values from config file" do
       @config.data[:login].should == "test@gmail.com"
       @config.data[:password].should == "myPassword"
     end
  end

  context "An non-existent configuration file" do
    before(:all) { @config = Bitsa::ConfigFile.new("/tmp/i-dont-exist") }
    it "should have no values" do
      @config.data.should == {}
    end
  end

  context "An existing configuration file that I have no read rights to" do
    before(:all) do
      @tmp_file = Tempfile.open("cache")
      FileUtils.cp("spec/data/config.yml", @tmp_file.path)
      FileUtils.chmod(0222, @tmp_file.path)
    end

    it "should throw an exception when I try to read from it" do
      lambda { Bitsa::ConfigFile.new(@tmp_file.path) }.should raise_error(Errno::EACCES)
    end
  end

end
