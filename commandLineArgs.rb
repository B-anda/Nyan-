require 'getoptlong'

def getOpts()
    opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--debug', '-d', GetoptLong::OPTIONAL_ARGUMENT],
    [ '--version', '-v', GetoptLong::OPTIONAL_ARGUMENT]
    # [ '-log true', GetoptLong::OPTIONAL_ARGUMENT ]
    )

    opts.each do |opt, arg|
        puts arg
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
        when '--debug'
            case arg
            when "off"
                run(false)
            when "on"
                run(true)
            end
        when '--version'
            puts "Nyan ≈^0.0^≈"
        end 
    end
        

end