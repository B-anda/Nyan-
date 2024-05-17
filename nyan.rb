require './parser'
require 'getoptlong' # require the GetoptLong library for command-line option parsing

@nyan = Nyan.new

# Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

# Parse
def run(setDebug = false)
    input = 0
    
    loop do
        print "~^nyan^~ "   # promt for input
        input = gets        # get input from the user

        if done(input) then # check if the input is an exit command
            puts "Bye Bye~"
            break
        else
            @nyan.log setDebug            
            @nyan.nyanParser.parse(input) # parse the input
        end
    end
end

# function to handle command-line arguments and flags
def getOpts()
    opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--debug', '-d', GetoptLong::OPTIONAL_ARGUMENT],
    [ '--version', '-v', GetoptLong::OPTIONAL_ARGUMENT],
    )

    fileName = ARGV[0]  # get the first argument (file name)
    setDebug = false    # default debug mode is false

    # iterate over the provided options
    opts.each do |opt, arg|
        case opt
        when '--help'
            # display help message
            puts <<-EOF
            Nyan [OPTION] ... [flag | file] [arg]
            Options:
            -h, --help   : show help 
            -d --debug   : Set debug mode true/false 
            -v --version : show latest version 
            file         : program read from script file
            EOF
            return
        when '--debug'
            # set debug mode based on the argument
            case arg
            when "false"
                setDebug = false
            when "true"
                setDebug = true
            end
        when '--version'
            # display version information
            puts "Nyan ≈^0.0^≈"
            return
        end 
    end

    begin 
        # check if the file exists and has a -nyan extension
        if File.exist?(fileName) && File.extname(fileName) == ".nyan"
            readFile(fileName, setDebug)
        else
            run(setDebug) # start the sun loop if no file is provided
        end
        
    rescue Errno::ENOENT => e
        puts e.message
        puts "File does not exist"
    end
   
end

# function to read and parse a file 
def readFile(fileName, debug)
    @nyan.log debug
    begin
        file = File.open(fileName)      # opern the file
        lines = file.readlines.join     # read all lines and join them into a single string
        @nyan.nyanParser.parse(lines)   # parse the file content

    rescue Parser::ParseError => e
        puts "#{e.message}"             # handle parsing errors
    end
end

## Start program ##
if ARGV.length == 0 
    run()       # start interactive mode if no arguments are provided
else
    getOpts()   # process command-line arguments
end



