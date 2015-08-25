
class Market
{
  
  static const Str[] validTypes := ["Market", "MarketMaker", "Limit", "Stop"]
  static const Int MARKET_DEPTH := 10
  Bool debug
  Bool verbose
  [Str:Order[]] allBuys := ["A":[,], "B":[,], "C":[,], "D":[,], "E":[,]]
  [Str:Order[]] allSells := ["A":[,], "B":[,], "C":[,], "D":[,], "E":[,]]
  Order[] buys := [,]
  Order[] sells := [,]
  Order[] mBuys := [,]
  Order[] mSells := [,]
  [Str:Int] prices := ["A":100, "B":100, "C":100, "D":100, "E":100]
  
  new make(Bool debug, Bool verbose){
    this.debug = debug
    this.verbose = verbose
  }
  
  |Order, Order -> Int| c := |Order a, Order b -> Int|{
    if(a.type == "Market"){
      if(b.type != "Market") return -1
      else if(a.price != b.price) return a.price <=> b.price
      else return a.quantity <=> b.quantity
    }
    else if(b.type == "Market") return 1
    else{
      if(a.price != b.price) return a.price <=> b.price
      else return a.quantity <=> b.quantity
    }
  }
  
  |Order, Order -> Int| q := |Order a, Order b -> Int|{
    return a.quantity <=> b.quantity
  }
  
  |Order, Order -> Int| l := |Order a, Order b -> Int|{
    return a.limit <=> b.limit
  }
  
  |Order, Order -> Int| a := |Order a, Order b -> Int|{
    return a.age <=> b.age
  }
  
  public Void cycle(Order[] orders){
    prices.each|Int p, Str stock|{
      //Stir the pot
      Int change := Int.random(-(p/20)..(p/20))
      prices.set(stock, p + change)
      
      //Match up all the orders
      buys := orders.findAll { it.stock == stock && it.direction == 1 }
      sells := orders.findAll { it.stock == stock && it.direction == -1 }
      match(buys, sells, stock)
    }
      
  }
  
  private Void match(Order[] bb, Order[] ss, Str stock){
    
    //Add orders, shuffle so broker position doesn't matter
    buys = allBuys.get(stock).addAll(bb).shuffle
    sells = allSells.get(stock).addAll(ss).shuffle
    

    //Evaluate all marketMakers first
    buys.findAll|Order o ->Bool|{o.type == "MarketMaker"}.each|Order o|{evaluate(o); buys.remove(o)}
    sells.findAll|Order o ->Bool|{o.type == "MarketMaker"}.each|Order o|{evaluate(o); sells.remove(o)}
    
    //Market orders
    mBuys = buys.findAll|Order o ->Bool|{o.type == "Market"}.sort(q)
    mSells = sells.findAll|Order o ->Bool|{o.type == "Market"}.sort(q)
    
    buys.removeAll(mBuys)
    sells.removeAll(mSells)
    
    //Match with each other first
    while(mBuys.size > 0 && mSells.size > 0){
      
      b := mBuys.pop
      s := mSells.pop
      b.price = prices.get(stock)
      s.price = prices.get(stock)
      //if(debug) echo("Matching markets: $b with $s")
      if(b.quantity > s.quantity){
        evaluate(s)
        clone := b.clone
        clone.quantity = s.quantity
        b.quantity -= s.quantity
        evaluate(clone)
        mBuys.push(b)
      }
      else if(b.quantity == s.quantity){
        evaluate(b)
        evaluate(s)
      }
      else{
        evaluate(b)
        clone := s.clone
        clone.quantity = b.quantity
        s.quantity -= b.quantity
        evaluate(clone)
        mSells.push(s)
      }
      
      //Update Stop orders
      updateStops(prices[stock])
    }
    
    //Fulfill from other orders
    sells.sortr(l)
    buys.sort(l)
    for(Int i := 0; i < mBuys.size; i++){
      o := mBuys.get(i)
      if(consume(o, sells)) i--
      updateStops(prices[stock])
    }
    for(Int i := 0; i < mSells.size; i++){
      o := mSells.get(i)
      if(consume(o, sells)) i--
      updateStops(prices[stock])
    }
    updateStops(prices[stock])
    
    
    
    
    buys.sort(q)
    
    //Evaluate the rest of the orders
    buys.findAll{it.type != "Stop"}.each| Order o|{
      sellers := sells.findAll |Order s -> Bool| { s.limit <= o.limit && s.type != "Stop"}.sortr(l)
      sells.removeAll(sellers)
      consume(o, sellers)
    }
    
    
    //Clean
    buys.addAll(mBuys)
    sells.addAll(mSells)
    emptyBuys := buys.findAll|Order o -> Bool| { o.quantity <= 0}
    emptySells := buys.findAll|Order o -> Bool| { o.quantity <= 0}
    buys.removeAll(emptyBuys)
    sells.removeAll(emptySells)
    
    //Trim
    if(buys.size > MARKET_DEPTH){
      if(debug) echo("Removing old buys from $stock")
      if(debug) echo("buys before: $buys.size")
      buys = buys.sort(a)[0..MARKET_DEPTH - 1]
      if(debug) echo("buys after: $buys.size")
    }
    if(sells.size > MARKET_DEPTH){
      sells = sells.sort(a)[0..MARKET_DEPTH - 1]
    }
    buys.each{it.age++}
    sells.each{it.age++}
    
    //Re-send to stock market
    allBuys.set(stock, buys)
    allSells.set(stock, sells)
  }
  
  private Void evaluate(Order a){
    //if(verbose) echo("\tEvaluating $a from $a.owner.name")
    Int direction := a.direction
    switch(a.type){
      case "MarketMaker":
        Int price := prices.get(a.stock) * (100 + 5*direction) / 100
        prices.set(a.stock, price)
        a.owner.bank += price*a.quantity*-1*direction
        a.owner.changeStock(a.stock, a.quantity*direction)
      default:
        prices.set(a.stock, a.price)
        a.owner.bank += a.price*a.quantity*direction*-1
        a.owner.changeStock(a.stock, a.quantity*direction)
    }
    updateStops(prices[a.stock])
  }
  
  private Bool consume(Order o, Order[] trades){
    if(verbose) echo("Trying to consume $o from $o.owner.name")
    Int price := 0
    while(trades.size > 0 && o.quantity > 0){
        s := trades.pop
        if(o.type == "Market"){ price = s.limit }
        else price = (s.limit + o.limit) / 2
        s.price = price
        o.price = price
        if(o.quantity > s.quantity){
          evaluate(s)
          clone := o.clone
          clone.quantity = s.quantity
          o.quantity -= s.quantity
          evaluate(clone)
        }
        else{
          evaluate(o)
          clone := s.clone
          clone.quantity = o.quantity
          s.quantity -= o.quantity
          evaluate(clone)
          trades.push(s)
        }
    }
    return o.quantity > 0
  }
  
  private Bool updateStops(Int price){
    //Create market orders for buys
    b := buys.findAll { it.type == "Stop" && it.limit >= price  }
    buys.removeAll(b)
    m := b.map |Order o -> Order|{
      o.type = "Market"
      o.limit = null
      o.age = 0
      return o
    }
    mBuys.addAll(m)
    mBuys.sort(q)
    
     //Create market orders for sells
    s := sells.findAll { it.type == "Stop" && it.limit <= price  }
    sells.removeAll(s)
    r := s.map |Order o -> Order|{
      o.type = "Market"
      o.limit = null
      o.age = 0
      return o
    }
    mSells.addAll(r)
    mSells.sort(q)
    return (m.size>0 || r.size >0)
    
  }
  
  override Str toStr(){
    Str priceString := prices.join(",") |Int val, Str key ->Str|{ return val.toStr}
    Str buyBlock := allBuys.join(" ") |Order[] val, Str key ->Str|{ return val.toStr.replace("[", "").replace("]", "")}.replace(" ,", "")
    Str sellBlock := allSells.join(" ") |Order[] val, Str key ->Str|{ return val.toStr.replace("[", "").replace("]", "")}.replace(" ,", "")
    
    return (priceString + " {" + buyBlock + " " + sellBlock + "}").replace("{, ","{").replace(",}","}")
  }
}
