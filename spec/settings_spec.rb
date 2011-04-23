require "helper"
require "bitsa/config_file"
require "bitsa/settings"

describe Bitsa::Settings do
  context "An existing Settings object" do

    it "should read a value from config file if it wasn't passed in options" do
     settings = load_settings({})
     settings.login.should == "test@gmail.com"
     settings.password.should == "myPassword"
   end

    it "should use values passed in options to override those in the config file" do
       settings = load_settings({:login => "somebody@example.com"})
       settings.login.should == "somebody@example.com"
    end

    it "should still use values in config file when other options passed" do
       settings = load_settings({:login => "somebody@example.com"})
       settings.password.should == "myPassword"
     end

  end

  private

   def load_settings(options)
     settings = Bitsa::Settings.new
     settings.load(Bitsa::ConfigFile.new("spec/data/config.yml"), options)
     settings
   end

 end
