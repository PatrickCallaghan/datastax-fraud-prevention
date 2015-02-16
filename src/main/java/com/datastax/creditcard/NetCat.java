package com.datastax.creditcard;

import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

import com.datastax.demo.utils.FileUtils;

public class NetCat {

	public static void main(String args[]) {
		try {

			List<String> transactions = FileUtils.readFileIntoList("Transactions.csv");

			ServerSocket serverSocket = new ServerSocket(9999);
			Socket clientSocket = serverSocket.accept();
			PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

			int counter = 0;
			
			for (String transacton : transactions) {

				out.write(transacton + "\n");				
				out.flush();
				
				if (++counter % 10000 == 0){
					System.out.println("Processed " + counter + " transactions");
				}
			}

			serverSocket.close();
			clientSocket.close();

		} catch (Throwable e) {
			e.printStackTrace();
		}

	}
}
