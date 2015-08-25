package ProcessRunner;

import java.io.*;
import java.util.Scanner;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class Wrapper {
	Process process;
	BufferedReader reader;
	BufferedWriter writer;
	Scanner scan;
	ExecutorService executor; 
	
	public Wrapper(String command){
		start(command);
		executor = Executors.newFixedThreadPool(1);
	}
	
	public String call(String args, long timeout) throws InterruptedException, ExecutionException, TimeoutException{
		if(args.length() > 4000) return "Args too long";
		try {
			writer.write(args + "\n");
			writer.flush();
		} catch (IOException e) {
			System.err.println("Could not write");
			//e.printStackTrace();
		}
		
		
		Callable<String> readTask = new Callable<String>() {
			@Override
			public String call() throws Exception {
				return reader.readLine();
			}
		};
		
		Future<String> future = executor.submit(readTask);
		
		return future.get(timeout, TimeUnit.MILLISECONDS);
		
	}
	
	public void start(String command) {
		try {
			//System.out.println("Starting remote process");
			ProcessBuilder pb = new ProcessBuilder(command.split(" "));
			pb.redirectErrorStream(true);
			process = pb.start();
			//System.out.println("Process process begun");
			// STDOUT of the process.
			reader = new BufferedReader(new InputStreamReader(process.getInputStream(), "UTF-8")); 
			scan = new Scanner(reader);
			//System.out.println("Process reader stream grabbed");
			// STDIN of the process.
			writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream(), "UTF-8"));
			//System.out.println("Process writer stream grabbed");
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Process ended catastrophically.");
		}
	}
	
	public void stop() throws IOException{
		scan.close();
		reader.close();
		writer.flush();
		writer.close();
		process.destroyForcibly();
		executor.shutdownNow();
	}
}
