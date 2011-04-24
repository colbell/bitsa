# Bitsa

* <http://github.com/colbell/bitsa>


A command line tool to access your GMail/Google Apps contacts. Designed to be used
from Mutt but should be able to be used from any email client that
supports calling external programs.


## Installation

**Note** You need to pass the `--prerelease` flag in order to install
this beta gem.

    gem install --prerelease  bitsa


## Configuration 

Bitsa is configured through the configuration file
`~/.bitsa_config.yml`. Use your GMail (or Google Apps) email address
for the login.

    ---
    :login: myself@gmail.com
    :password: mypassword
    :cache_file_path: ~/.bitsa_cache.yml

The configuration file is not mandatory, you can pass in your email address
and password on the command line, see [Usage](#usage).    

If you have no configuration file or if `cache_file_path` is not specified in the
configuration file it will default to `~/.bitsa_cache.yml`

If you store your email password in the configuration file you should
ensue that it is only readable by you:

    chmod 0600 .bitsa_config.yml


## <a name="usage">Usage</a>

    Usage: bitsa [global-options] [subcommand] [command-opts]
    
    Global options are:
      --config-file, -c <s>:   Configuration file (default: ~/.bitsa_config.yml)
            --login, -l <s>:   Login
         --password, -p <s>:   Password
    
    bitsa sub-commands
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
    bob@robertsystems	Robert Brown

The first time you run Bitsa and then if it has been more than a day
since it was last updated it will get the latest changes from your
GMail contacts and copy them to a local cache (~/.bitsa_cache.yml).

You can update your cache with the latest changes at any time by using
the `update` sub-command:

    $ bitsa update

If you want to clear your local cache and reload from GMail use the
`reload` sub-command:

    $ bitsa reload

## Usage - Mutt

To use for address lookup (&lt;ctrl&gt; t) in Mutt put the following in your
`~/.muttrc` file:

    set query_command = "bitsa search '%s'"

## Testing

To run the tests after cloning the repository you first need to
install the required libraries:

    bundle install

And then you can run the tests:

    rake spec

## License:

Copyright 2011 Colin Bell.

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
