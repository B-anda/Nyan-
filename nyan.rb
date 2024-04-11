require './parser'
require './commandLineArgs'

@nyan = Nyan.new

#Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

def run(debugCon = true)
    input = 0
    loop do
        print "~^nyan^~ "
        input = gets

        if done(input) then
            puts "Bye Bye~"
            break
        else
            @nyan.log debugCon
            puts @nyan.nyanParser.parse input
        end
    end
end

def readFile(fileName)
    File.foreach(fileName) { |line| @nyan.nyanParser.parse line }
end

#Start program
if ARGV.length == 0 
    run()
else
    getOpts()
    if File.exists?(ARGV[0])
        readFile(ARGV[0])
    end
end



