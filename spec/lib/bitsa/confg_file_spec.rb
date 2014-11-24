require "tempfile"
require "helper"
require "bitsa/config_file"

describe Bitsa::ConfigFile do
  context "An existing configuration file should load from disk" do
    let(:config) { Bitsa::ConfigFile.new("spec/data/config.yml")}
     context :login do
       specify { expect(config.data[:login]).to eq("test@gmail.com") }
     end
     context :password do
       specify { expect(config.data[:password]).to eq("myPassword") }
     end
  end

  context "data from a non-existent configuration files" do
    let(:config) { Bitsa::ConfigFile.new("/tmp/i-dont-exist") }
    specify { expect(config.data).to eq({}) }
  end

  context "that I have no rights to" do
    let(:tmp_file) {
      tmp_file = Tempfile.open("cache")
      FileUtils.cp("spec/data/config.yml", tmp_file.path)
      FileUtils.chmod(0000, tmp_file.path)
      tmp_file
    }

    context "reading" do
      specify { expect { Bitsa::ConfigFile.new(tmp_file.path) }.to raise_error(Errno::EACCES) }
    end
  end

end
