require './parser'
require 'getoptlong'

@nyan = Nyan.new

# Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

# Parse
def run(setDebug = true)
    input = 0
    loop do
        print "~^nyan^~ "
        input = gets

        if done(input) then
            puts "Bye Bye~"
            break
        else
            @nyan.log setDebug
            puts @nyan.nyanParser.parse input
        end
    end
end

# Commandline argumnts/flags
def getOpts()
    opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--debug', '-d', GetoptLong::OPTIONAL_ARGUMENT],
    [ '--version', '-v', GetoptLong::OPTIONAL_ARGUMENT],
    )

    fileName = ARGV[0]
    setDebug = true

    opts.each do |opt, arg|
        case opt
        when '--help'
            puts <<-EOF
            Nyan [OPTION] ... [flag | file] [arg]
            Options:
            -h, --help   : show help 
            -d --debug   : Set debug mode on/off 
            -v --version : show latest version 
            file         : program read from script file
            EOF
            return
        when '--debug'
            case arg
            when "off"
                setDebug = false
            when "on"
                setDebug = true
            end
        when '--version'
            puts "Nyan ≈^0.0^≈"
            return
        end 
    end

    if File.exist?(fileName)
        readFile(fileName, setDebug)
    else
        run(setDebug)
    end
end

def readFile(fileName, debug)
    @nyan.log debug
    # File.foreach(fileName) { |line| puts @nyan.nyanParser.parse line.chomp }
    File.foreach(fileName) do |line|
        begin
          result = @nyan.nyanParser.parse(line.chomp)
          puts "Parsed result: #{result.inspect}"
        rescue Parser::ParseError => e
          puts "Parsing error on line '#{line.chomp}': #{e.message}"
        end
    end
end

## Start program ##
if ARGV.length == 0 
    run()
else
    getOpts()
end



