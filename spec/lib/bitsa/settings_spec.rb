require "helper"
require "bitsa/config_file"
require "bitsa/settings"

describe Bitsa::Settings do
    it "should read a value from config file if it wasn't passed in options" do
     settings = load_settings({})
     expect(settings.login).to eq "test@gmail.com"
     expect(settings.password).to eq "myPassword"
   end

    it "should use values passed in options to override those in the config file" do
       settings = load_settings({:login => "somebody@example.com"})
       expect(settings.login).to eq "somebody@example.com"
    end

    it "should still use values in config file when other options passed" do
      settings = load_settings({:login => "somebody@example.com"})
      expect(settings.password).to eq "myPassword"
    end

  private

   def load_settings(options)
     settings = Bitsa::Settings.new
     settings.load(Bitsa::ConfigFile.new("spec/data/config.yml"), options)
     settings
   end

 end
