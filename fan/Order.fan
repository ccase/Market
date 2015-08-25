
class Order
{
  Str type := "Market"
  Int direction 
  Str stock := "A"
  Int? price := null
  Int quantity := 10
  Int? limit := null
  Int age := 0
  Broker owner
  
  
  new make(Broker o, Int d, Str t, Str s, Int q, Int? l){
    owner = o
    direction = d
    type = t
    stock = s
    quantity = q
    limit = l
  }
  
  static Order? fromStr(Str s, Broker o){
    try{
      Str[] data := s.split(',')
      Str type := data[0]
      Int direction := Int.fromStr(data[1])
      Str stock := data[2]
      Int? price := Int.fromStr(data[3], 10, false)
      Int quantity := Int.fromStr(data[4])
      Int? limit := Int.fromStr(data[5], 10, false)
      Broker owner := o
      if(!Market.validTypes.contains(type)) return null
      return Order(o, direction, type, stock, quantity, limit)
    }
    catch{ return null}
    
  }
  
  Order clone(){
    Order o := Order(owner, direction, type, stock, quantity, limit)
    o.price = price
    return o
  }
  
  public Str longStr(){
    Str dir := direction == 1 ? "Buy" : "Sell"
    return "$type $dir $quantity $stock at $limit for $owner.id: price = $price"
  }
  
  override Str toStr(){
    return "$type,$direction,$stock,$price,$quantity,$limit,$age"
  }
}
