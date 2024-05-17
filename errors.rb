class NyantimeNyerror < StandardError

    def initialize(msg = "Nya suck.")
        super
    end
end

class NyanTypeError < StandardError

    def initialize(msg = "Nya have nyassined nyong nyalu to nyong datatype")
        super
    end
end

class NyanZeroNyerror < ZeroDivisionError

    def initialize(msg = "nyan nyan 0.")
        super
    end

end

class NyameNyerror < StandardError

    def initialize(msg = "Nyanyame nyanyajyuunyanya-do no nyarabi de nyakunyaku inyanyaku nyanyahan nyanyadai nyanynaku nyarabete nyaganyagame.")
        super
    end

end