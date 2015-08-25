using [java] ProcessRunner
class Broker
{
  Int id
  Str name
  Wrapper w
  Int bank := 5000
  [Str:Int] stocks := ["A":10, "B":10, "C":10, "D":10, "E":10]
  Int inDebt := 0
  Int oweStock := 0
  
  public Void changeStock(Str name, Int value){
    stocks.set(name, stocks.get(name) + value)
  }
  
  new make(Int i, Str command){
    id = i
    name = command.split(' ').last.split('.').first
    switch(command.split(' ').first){
      case "fan":
        command = command.split(' ').first + " res/" + command.split(' ').last
      case "java":
        command = command.split(' ').first + " -cp res " + command.split(' ').last
    }
    w = Wrapper(command)
    
    
  }
  
  Order[] getResponse(Str args, Int timeout){
 
    Str myStocks := stocks.join(",") | Int val, Str key->Str|{ val.toStr } 
    args = myStocks + " " + args
    Str? res := null
    try{res = w.call(args, timeout) } catch(Err e){ echo("$name timed out")}
    if(res == null) return [,]
    Order[] orders := res.split(' ').map|Str s -> Order?|{ return Order.fromStr(s, this)}.findAll{ it != null}
    
    return orders
  }
  
  Void kill(){
    w.stop();
  }
  
  Void liquidate([Str:Int] prices){
    prices.each |Int val, Str key| {
      bank += val * stocks.get(key)
      stocks.set(key, 0)
    }
  }
   
}
