# Bitsa

* <http://github.com/colbell/bitsa>


A command line tool to access your GMail contacts. Designed to be used
from Mutt but should be able to be used from any email client that
supports calling external programs.


## Installation

**Note** this gem has not yet been released and so this
installation step will not work.

    gem install bitsa


## Usage

    Usage: bitsa [global-options] [subcommand] [command-opts]
    
    Global options are:
      --config-file, -c <s>:   Configuration file (default: ~/.bitsa_config.yml)
            --login, -l <s>:   Login
         --password, -p <s>:   Password
    
    bitsa subcommands
       update: get the latest changes from Gmail
       reload: Clear all cached addresses and reload from Gmail
       search: Search for the passed string
    
    Information about this program
              --version, -v:   Print version and exit
                 --help, -h:   Show this message
    

To search for all contacts that contain the string rob:

    $ bitsa search rob
    
    Rob_Smith@example.com.au	Robert Smith
    Rob_Smith@example.com  	Robert Smith
    robert@example.com	        Robert Jones
    jeff@example.net	Robert Smith
    robert@robertsystems	Robert Brown

* TODO: Config file
* TODO: auto-refresh
    
## Testing

To run the tests after cloning the repository you first need to
install the required libraries:

    bundle install

And then you can run the tests:

    rake spec

## License:

Copyright 2010 Colin Bell.

This file is part of Bitsa.

Bitsa is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

* * * * *
