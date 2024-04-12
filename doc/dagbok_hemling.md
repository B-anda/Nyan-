# 2024-02-26

Idag arbetade vi vidare på _språkspecen_. Vi lade till _BNF grammatiken_. Vi gjorde beslutet att ha _dynamisk scopehantering_ eftersom det i teorin är lättare att implementera.

Utöver det valde vi att skriva ett _imperativt programmeringsspråk_, något som skulle efterlikna python.

# 2024-03-25

Idag arbetade vi med en mer detaljerad _implementationsplan_ för hur vi ska arbeta de kommande veckorna. Enligt implementationsplanen planerar vi att ha ett _återkopplingsmöte_ på måndagar för att se över hur vi ligger till med arbetet så vi kan balansera det med andra kurser.

# 2024-03-26

Vi skapade ett utkast för _språkdokumentationen_ och en _filstruktur_ för projektarbetet. Vi delade upp filerna baserat på dess funktionalitet, där en fil används för tester, en för parsern (den hämtar in rdparse), en fil för funktioner och klasser etc.

# 2024-03-27

En stor del av dagen gick till att förstå hur vi skulle börja men till slut lyckades vi påbörja _scope hanteringen_ och _parsning_ enligt våran planering.

# 2024-03-28

Vi hade till en början _problem_ med parsningen men insåg att felet var på grund av regex uttrycket som matchade fel. Vi insåg däremot att matchningen inte hämtar hela matchgruppen.

I funktionen _run()_ lades det till en _loop_ så att programmet fortsätter köra efter varje parsning.

prövade ett annorlunda _objekthanteringssystem_ som efterliknade syntaxträd mer.

_component_ matchgruppen kallar _eval_ genom hela syntaxträdet.

# 2024-04-02

_Print_ funkar delvis nu, strängar och andra värden går att skriva ut men _variabler funkar ej_.

Ett simpelt _scopehanteringssystem_ testas.

# 2024-04-03

_Print_ fungerar som den ska och kan skriva ut string, int och variabler.

_Scopehantering_ fungerar nu.

Påbörjade _tester_ för conditions.

Planen är att vi ska lägga till så att strings och chars hanteras separat samt att floats ska funka ordentligt, för tillfället matchar de inte rätt.

# 2024-04-04

LogicExpr klassen hanterar Variable- och Valuenoder separat och returnerar antingen true eller false.

Vi har skrivit fler tester.

I test filen har vi implementerat en assert_output funktion som kör nyan kod och parsar den.

Initierade scope i initialize även om vi vet att det finns mer generella lösningar.

__Problem__

Samma scopeproblem för PrintNode som tidigare.

Scope behöver hanteras i rules för LogicExpr.

Tokens skapas inte korrekt vilket leder till att det inte går att parsa den nyankoden vi har just nu.

Det går tekniskt sätt att parsa assignement och print men inte för de testerna vi har.

# 2024-04-05

Problem med global scope, utöver det har vi skrivit om SyntaxTreeNode och ProgramNode klasserna.

Vi hade problem med att eval() funktionen eftersom den ibland skulle ta in en parameter för scope. Vi löste detta med att eval alltid tog in *scope så att eval gick att anropa även utan parametrar.

Vi delade upp syntaxtree.rb filen så att syntaxträdets nodklasser och logik klasser är i separata filer. Den andra filen är condition.rb.

# 2024-04-08

Vi blev klara med tester och började lägga till scope och tester för dem.

# 2024-04-09

Vi fortsatte skriva klart tester flr global scope.

testSyntaxtree.rb klarar inte alla tester.

Vi skapade custom error meddelanden för att det verkade kul.

Vi skapade en funktion currToPrevScope() för scope klassen som flyttar en ut från det senaste scopet.

# 2024-04-10

Vi skrev vidare på tester, däremot vet vi inte hur vi ska testa parsning för nyankod, det finns ingen assert_output() funktion inbyggd i testunit. dvs finns ingen assert för att testa utskrifter i terminalen.

Började med aritmetik.

# 2024-04-11

Implementerat en toValue() funktion som skiljer på ValueNode och VariableNode. toValue() funktionen ligger i modulen GetValue som inkluderas i de klasser som den används i.

Lade till filinläsning för programmet, om ingen fil anges vid körning startar det interaktiva läget. Vid fallet att en fil anges körs getOpts() som antingen läser in en fil från ARGV[0] om filen existerar, annars körs programmet som vanligt beroende på angivna flaggor.

Felsökt tester men fastnade på att tokens inte konsumeras.

Aritmetiken är färdigskriven, det ska funka som det ska.