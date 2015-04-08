# Loads configuration data from configuration file.
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

require 'yaml'

module Bitsa #:nodoc:
  # Loads configuration data from a yaml file.
  class ConfigFile
    # Loaded configuration data as a Hash.
    attr_reader :data
    # @!attribute [r] data
    #   @return [Hash] Settings from configuration file.

    # Load configuration data from passed file path.
    #
    # @param [String] config_file_path_name Path of file to load.
    def initialize(config_file_path_name)
      c_f_n = File.expand_path(config_file_path_name)
      @data = YAML.load_file(c_f_n) if File.exist?(c_f_n)
      @data = {} unless @data
    end
  end
end
