# Application settings.
#
# Copyright (C) 2011-2015 Colin Noel Bell.
#
# This file is part of Bitsa.
#
# Bitsa is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Bitsa #:nodoc:
  # Application settings.
  #
  # @example
  #
  #   s = Settings.new(Bitsa::ConfigFile.new('~/.bitsa.yml'))
  #   s.login # => 'test@gmail.com'
  class Settings
    # Login to use to connect to GMail/Google Apps. Your email
    # address.
    #
    # @return [String] Login to use to connect to GMail.
    #
    # @!attribute [r] login
    attr_reader :login

    # Password to use to connect to GMail/Google Apps.
    # @return [String] Password to use to connect to GMail.
    #
    # @!attribute [r] password
    attr_reader :password

    # Path to file to store cached contact information in.
    #
    # @return [String] Path of file to store contacts in.
    #
    # @!attribute [r] cache_file_path
    attr_reader :cache_file_path

    # Number of days before auto checking if updates exist
    #
    # @return [Integer] Number of days before auto checking if updates exist
    #                   in GMail, zero means never auto-check
    # @!attribute [r] auto_check
    attr_reader :auto_check

    # Load settings from a hash of data from the configuration file and
    # options passed on the command line.
    #
    # Options passed on the command line override those in the
    # configuration file.
    #
    # @param  [Hash] config_file_hash <tt>Hash</tt> of settings loaded from
    #                                 configuration file.
    # @param  [Hash] options <tt>Hash</tt> of settings passed on command line.
    #
    # @return [nil]
    def load(config_file_hash, options)
      load_config_file_settings(config_file_hash)
      load_cmd_line_settings(options)

      @auto_check ||= 1
      @cache_file_path ||= '~/.bitsa_cache.yml'
    end

    private

    # Load settings from the configuration file hash.
    #
    # @param  [Hash] config_file_hash <tt>Hash</tt> of settings loaded from
    #                                 configuration file.
    def load_config_file_settings(config_file_hash)
      @login = config_file_hash.data[:login]
      @password = config_file_hash.data[:password]
      @cache_file_path = config_file_hash.data[:cache_file_path]
      @auto_check = config_file_hash.data[:auto_check]
    end

    # Load settings from the command line hash. Load a setting only if it was
    # passed.
    #
    # @param  [Hash] options <tt>Hash</tt> of settings passed on command line.
    def load_cmd_line_settings(options)
      @login = options[:login] if options[:login]
      @password = options[:password] if options[:password]
      @cache_file_path = options[:cache_file_path] if options[:cache_file_path]
      @auto_check = options[:auto_check] if options[:auto_check]
    end
  end
end
