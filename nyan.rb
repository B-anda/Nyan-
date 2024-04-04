require './parser'

@nyan = Nyan.new



#Exit 
def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
 end

def run(input = 0)
    loop do
        print "~^nyan^~ "
        input = gets

        if done(input) then
            puts "Bye Bye~"
            break
        else
            @nyan.log false
            puts "=> #{@nyan.nyanParser.parse input}"
        end
    end
end


#Start program
if ARGV.length == 0
    run()
else
    run_file()
end



