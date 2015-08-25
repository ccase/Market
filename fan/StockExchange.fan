
class StockExchange
{

  const static Int TICKS := 500
  const static Int DEBT_DUE_PERIOD := 5
  const static Int STOCK_DUE_PERIOD := 5
  const static Int TIMEOUT := 1000
  
  public static Void main(){
    run(null, true, true, true)
  }
  
  public static Broker[] run(Str? players,Bool debug, Bool verbose, Bool verboseMarket){
    
    Str playerFile := players ?: "file:res/players"
    
    //Build the players
    if(debug) echo("Initializing")
    Broker[] brokers := [,]
    Broker[] jail := [,]
    File(playerFile.toUri).readAllLines.each|Str line, Int row|{
      brokers.add(Broker(row, line))
    }
    
    //Start the marker
    m := Market(debug, verboseMarket)
    
    //Play
    TICKS.times{
      if(debug) echo("Getting orders...")
      Order[] orders := [,]
      brokers.each{
        if(debug) echo("Sending $it.name $m.toStr")
        orders.addAll(it.getResponse(m.toStr, TIMEOUT))
      }
      
      if(debug) echo("Cycling...")
      m.cycle(orders)
      
      //Check for naughty brokers
      if(debug) echo("Evaluating Brokers...")
      brokers.each{
        
        //Broke?
        if(it.bank < 0){
          it.inDebt++
        }
        else{
          it.inDebt = 0
        }
        
        //Owe some stocks?
        Bool owe := false
        it.stocks.each |Int val, Str key| {if(val < 0) owe = true}
        if(owe){
          it.oweStock++
        }
        else{
          it.oweStock = 0
        }
        
        //Done fucked up?
        if(it.inDebt > DEBT_DUE_PERIOD || it.oweStock > STOCK_DUE_PERIOD){
          jail.add(brokers.remove(it))
          if(verbose)echo("$it.name is in jail!")
        }
        
      }
      
      //Status
      if(verbose){
        echo("Cycle $it")
        echo("Status...")
        echo("\t $m.prices")
        brokers.each{ echo("\t $it.name $it.stocks \$$it.bank") }
      }
    }
    
    //Who won?
    brokers.addAll(jail)
    brokers.each{
      it.kill
      it.liquidate(m.prices)
    }
    
   brokers.sortr |Broker a, Broker b ->Int| { a.bank <=> b.bank}
   if(verbose){
     echo("Jailed:")
     jail.each{ echo("\t $it.name") }
     echo("Round results")
      brokers.each{ echo("\t $it.name \$$it.bank") }
   }
   return brokers
    
    
    
  }
}
