# Command line arguments handler
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

require 'trollop'

require 'bitsa/version'

module Bitsa #:nodoc:
  # Arguments passed on the command line. Trollop http://trollop.rubyforge.org
  # is used to handle the parsing.
  class ArgsProcessor
    # Valid commands.
    SUB_COMMANDS = %w(update reload search skel)

    # Global options passed on the command line.
    attr_reader :global_opts

    # The command to execute
    attr_reader :cmd

    # Data to search cached contacts for.
    attr_reader :search_data

    # Parse arguments and setup attributes. If invalid data is passed a
    # Trollop exception is thrown and the program terminated.
    #
    # It also handles showing the Help and Version information.
    def parse(args)
      @global_opts = create_global_args(args)

      @cmd = args.shift || ''
      @search_data = ''

      if cmd == 'search'
        @search_data << args.shift unless args.empty?
      elsif !ArgsProcessor::SUB_COMMANDS.include?(cmd)
        Trollop.die "unknown subcommand '#{cmd}'"
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def create_global_args(args)
      Trollop.options(args) do
        version "bitsa v#{Bitsa::VERSION}"
        banner <<EOS
Usage: bitsa [global-options] [subcommand] [command-opts]

Global options are:
EOS
        opt :config_file, 'Configuration file',
            type: String, default: '~/.bitsa_config.yml'
        opt :auto_check,
            'Autocheck interval in days. 0 to disable (default: 1)',
            type: Integer
        opt :login, 'Login', type: String
        opt :password, 'Password', type: String

        stop_on SUB_COMMANDS

        banner <<EOS

bitsa subcommands
   update: get the latest changes from Gmail
   reload: Clear all cached addresses and reload from Gmail
   search: Search for the passed string
   skel:   Write a skeleton configuration file to standard output

Information about this program
EOS
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
