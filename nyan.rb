require './parser'

@nyan = Nyan.new

def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
 end

def run(input = 0)
    print "~^nyan^~ "
    input = gets

    if done(input) then
        puts "Bye Bye~"
    else
        # @nyan.log false
        puts "=> #{@nyan.nyanParser.parse input}"
    end
end

if ARGV.length == 0
    run()
end




