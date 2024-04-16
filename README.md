# Nyan.rb

Nyan.rb is a Ruby script that provides a command-line interface for interacting with the Nyan parser. It allows users to parse Nyan syntax and provides options for debugging and version information.

### Usage
ruby nyan.rb

### To run the script without any command-line arguments:
ruby nyan.rb [file] [flags]

#### Flags
-h, --help: Display help information.\
-d, --debug: Set debug mode on or off. \
-v, --version: Display the latest version.\
\
file         : program read from script file 

### Features
Parses Nyan syntax. \
Provides debugging mode for verbose output. \
Handles command-line arguments and file parsing. 

### Dependencies
parser.rb: This script is required for the Nyan parser functionality. \
getoptlong: Ruby library for parsing command-line options. 

### Example usage

// Run the script with debug mode off (debug is set to false by default)
ruby nyan.rb \

//Parse a file with debug mode on \
ruby nyan.rb my_file.nyan -d on

