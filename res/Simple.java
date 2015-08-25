import java.util.Scanner;


public class Simple {

	public static void main(String[] args){
		Scanner scan = new Scanner(System.in);
		boolean fake = true;
		while(fake){
			String market = scan.nextLine();
			fake = respond(market);
		}
		scan.close();
		System.err.println("SIMPLE HAS CLOSED!!!!!!!!!");
	}
	
	private static boolean respond(String market){
		int[] prices = new int[5];
		market = market.split(" ")[1];
		String[] priceStrings = market.split(",");
		for(int i = 0; i < priceStrings.length; i++){
			prices[i] = Integer.parseInt(priceStrings[i]);
		}
		
		//Highest price
		int highest = prices[0];
		int highestIndex = 0;
		int lowest = prices[0];
		int lowestIndex = 0;
		for(int i = 1; i < prices.length; i++){
			if(prices[i] > highest){
				highest = prices[i];
				highestIndex = i;
			}
			if(prices[i] < lowest){
				lowest = prices[i];
				lowestIndex = i;
			}
		}
		String[] stockType = {"A", "B", "C", "D", "E"};
		
		//sell 5 of the highest
		System.out.print("Market,-1," + stockType[highestIndex] + ",null,5,null");
		System.out.print(" ");
		//Buy 5 of the lowest
		System.out.println("Market,1," + stockType[lowestIndex] + ",null,5,null");
		
		return true;
	}
}
