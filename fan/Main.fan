using [java] ProcessRunner
class Main
{
  public static Void main(Str[] args){
    //vars
    Str? players := null
    Str? compile := null
    Int? runs := null
    Bool debug := false
    Bool verbose := false
    Bool verboseMarket := false
    
    
    //Parse args
    args.each|Str arg, Int index| {
      switch(arg){
        case "-p":
            players = "file:" + args[index + 1]
        case "-c":
            compile = "file:" + args[index + 1]
        case "-r":
            runs = Int.fromStr(args[index + 1])
        case "-d":
        case "-debug":
            debug = true
        case "-v":
        case "-verbose":
            verbose = true
        case "-vm":
        case "-verbosemarket":
            verboseMarket = true
      }
     }
    echo("Starting")
    play(players, compile, runs, debug, verbose, verboseMarket)
    
    
  }
  
  public static Void compile(Str? comp){
    compPath := comp?.toUri ?: `file:res/compile`
    //Build the files
    buildFile := File(compPath)
    buildFile.eachLine { 
      command := it.split(' ').first + " res/" + it.split(' ').last
      Utils.call(command)  }
    
  }
  
  private static Void play(Str? players, Str? comp, Int? runs, Bool debug, Bool verbose, Bool verboseMarket){
    compile(comp)
    Str:Int scores := [:]
    rounds := runs ?: 100
    rounds.times{
      echo("Round " + (it+ 1) + "...")
      results := StockExchange.run(players, debug, verbose,  verboseMarket)
      results.each|Broker b|{
        scores.set(b.name, scores.getOrAdd(b.name, |Str k->Int|{0}) + b.bank)
      }
    }
    scores.map |Int i->Int| { i / rounds}
    tuples := [,]
    scores.each |Int val, Str key| {  tuples.add(tuple(key, val)) }
    tuples.sortr| tuple a, tuple b -> Int| { a.score <=> b.score }
    tuples.each|tuple t, Int index|{
      echo("" + (index + 1) + ".\t $t.name \t $t.score")
    }
  }
  
  
}

class tuple{
    Str name
    Int score
    new make(Str n, Int i){
      name = n
      score = i
    }
  }
