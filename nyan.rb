require './parser'
require './commandLineArgs'
require 'optparse'

@nyan = Nyan.new



#Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
 end

def run(debugCon = false)
    input = 0
    loop do
        print "~^nyan^~ "
        input = gets

        if done(input) then
            puts "Bye Bye~"
            break
        else
            @nyan.log debugCon
            puts "=> #{@nyan.nyanParser.parse input}"
        end
    end
end



#Start program
if ARGV.length == 0 
    run()
else
    getOpts()
end



