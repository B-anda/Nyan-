require './parser'
require 'getoptlong'

@nyan = Nyan.new

# Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

# Parse
def run(setDebug = false)
    input = 0
    
    loop do
        print "~^nyan^~ "
        input = gets

        if done(input) then
            puts "Bye Bye~"
            break
        else
            @nyan.log setDebug
            @nyan.nyanParser.parse(input)
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
    setDebug = false

    opts.each do |opt, arg|
        case opt
        when '--help'
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
            case arg
            when "false"
                setDebug = false
            when "true"
                setDebug = true
            end
        when '--version'
            puts "Nyan ≈^0.0^≈"
            return
        end 
    end

    begin 
        if File.exist?(fileName) && File.extname(fileName) == ".nyan"
            readFile(fileName, setDebug)
        else
            run(setDebug)
        end
        
    rescue Errno::ENOENT => e
        puts e.message
        puts "File does not exist"
    end
   
end

def readFile(fileName, debug)
    @nyan.log debug
    begin
        # File.readlines(fileName).each do |line|
        #     puts @nyan.nyanParser.parse(line)
        # end
        file = File.open(fileName)
        lines = file.readlines.join
        @nyan.nyanParser.parse(lines)

    rescue Parser::ParseError => e
        puts "#{e.message}"
    end
end

## Start program ##
if ARGV.length == 0 
    run()
else
    getOpts()
end



