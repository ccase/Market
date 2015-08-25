using [java] ProcessRunner
class Test
{
  public static Void main(){
    
    
    
    
    m := Market(true, true)
    a := Broker(0, "")
    b := Broker(1, "")
    
    
    echo("Before deal:")
    echo("\tA money = $a.bank \t stocks = $a.stocks")
    echo("\tB money = $b.bank \t stocks = $b.stocks")
    
    orders := [,]
    //orders.add(Order(a,1, "Market", "A", 50, null))
    orders.add(Order(b,-1, "Market", "A", 5, null))
    orders.add(Order(b,-1, "Limit", "A", 5, 150))
    orders.add((Order(b,-1, "Limit", "B", 5, 200)))
    orders.add((Order(b,-1, "Limit", "A", 5, 200)))
    orders.add((Order(b,-1, "Limit", "D", 5, 200)))
    orders.add((Order(b,-1, "Limit", "A", 5, 200)))
    orders.add((Order(b,-1, "Limit", "C", 5, 200)))
    //orders.add(Order(b,1, "MarketMaker", "A", 5, null))
    
    m.cycle(orders)
    echo(m)
    echo("After deal:")
    echo("\tA money = $a.bank \t stocks = $a.stocks")
    echo("\tB money = $b.bank \t stocks = $b.stocks")
    
  }
}
