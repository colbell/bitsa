# Application settings.
#
# Copyright (C) 2011-2012 Colin Noel Bell.
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
  class Settings

    # Login to use to connect to GMail.
    attr_reader :login

    # Password to use to connect to GMail.
    attr_reader :password

    # Path to file to store cached contact information in.
    attr_reader :cache_file_path

    # Number of days before auto checking
    attr_reader :auto_check

    # Load settings from a hash of data from the configuration file and
    # options passed on the command line.
    #
    # Options passed on the command line override those in the
    # configuration file.
    def load(config_file_hash, options)
      @login = config_file_hash.data[:login]
      @password = config_file_hash.data[:password]
      @cache_file_path = config_file_hash.data[:cache_file_path]
      @auto_check = config_file_hash.data[:auto_check]

      @login = options[:login] if options[:login]
      @password = options[:password] if options[:password]
      @cache_file_path = options[:cache_file_path] if options[:cache_file_path]
      @auto_check = options[:auto_check] if options[:auto_check]

      @auto_check ||= 1
    end

  end
end
