require "helper"
require "bitsa/config_file"

describe Bitsa::ConfigFile do
  context "An existing configuration file" do
    let(:config) { Bitsa::ConfigFile.new("spec/data/config.yml")}
     it "should read values from config file" do
       expect(config.data[:login]).to eq("test@gmail.com")
       expect(config.data[:password]).to eq("myPassword")
     end
  end

  context "An non-existent configuration file" do
    let(:config) { Bitsa::ConfigFile.new("/tmp/i-dont-exist") }
    it "should have no values" do
      expect(config.data).to eq({})
    end
  end

  context "An existing configuration file that I have no rights to" do
    let(:tmp_file) {
      tmp_file = Tempfile.open("cache")
      FileUtils.cp("spec/data/config.yml", tmp_file.path)
      FileUtils.chmod(0000, tmp_file.path)
      tmp_file
    }

    it "should throw an exception when I try to read from it" do
      expect { Bitsa::ConfigFile.new(tmp_file.path) }.to raise_error(Errno::EACCES)
    end
  end

end
