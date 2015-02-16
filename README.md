Transaction Fraud Prevention
============================

NOTE - this example requires apache cassandra version > 2.0 and the cassandra-driver-core version > 2.0.0

## Scenario

You have been given 2 tables.  

1. credit_card_transactions_by_user - transactions with partition key user_id

2. credit_card_transactions_by_issuer_date - transactions with partition key issuer and date. 

You have also been told that there have been fraudulent transactions which include the following transaction ids.

ef1038b7-7c3f-4ef5-95a6-cb55a72c62e9,
6fc1bfe6-fa37-49cb-b78a-dfa4f167451b,
e29e7c27-cebe-4b78-a430-2c2fbab0123e,
91dd3b7e-179a-444b-9cfc-a7c627da4954,
f70a67ae-417b-4863-b984-b6264c9ff633,
fb81bd68-99a8-49bd-9b62-e75ca3f1fcf9,
d8e59cf5-a454-4fc6-b444-6862807b10d3,
4d580294-a713-47b9-aef0-338d664a2287

Task 1. 

Use Spark to discover all the fraudulent transactions based on the criteria of the above transactions. This will need some discovery work, looking at the fraudulent transactions against non-fraudulent transactions.

Task 2.

Based on the criteria found in Task 1, create a Spark Streaming job that opens a socket on port 9999 that will listen for incoming transactions. Transactions will be sent to this port with 8 fraudulent transactions and its your job to make sure they are send to a transactions_to_check table in DSE. 

NOTE : you can not change the existing tables in anyway - that includes no indexes. 


## Schema Setup
Note : This will drop the keyspace "datastax_transactions" and create a new one. All existing data will be lost. 

To specify contact points use the contactPoints command line parameter e.g. '-DcontactPoints=192.168.25.100,192.168.25.101'
The contact points can take mulitple points in the IP,IP,IP (no spaces).

To create the a single node cluster with replication factor of 1 for standard localhost setup, run the following

    mvn clean compile exec:java -Dexec.mainClass="com.datastax.demo.SchemaSetup"
    
To import the data into the table run the following - you need to check your file paths depending on where you are running cqlsh from

	copy credit_card_transactions_by_user from 'src/main/resources/transactions_by_user.csv';

	copy credit_card_transactions_by_issuer_date from 'src/main/resources/transactions_by_issuer.csv';    


The transactions file will send the data in the from

	credit_card_no, date, transaction_id, location, userdevice_location, amount
		
e.g.
	
	31855,Fri Jan 16 00:00:02 GMT 2015,e6075eda-8f60-4fff-8c51-113ed49af3c1,Exmouth,Exmouth,Starbucks,559.2749922477938

To start the processor to send Transactions to local port 9999, run

    mvn clean compile exec:java -Dexec.mainClass="com.datastax.creditcard.NetCat"     
	
To remove the tables and the schema, run the following.

    mvn clean compile exec:java -Dexec.mainClass="com.datastax.demo.SchemaTeardown"
    
    
##Hints - Streaming 
To get the data from the stream, you can use the following

	case class Transaction (user_id: String, date: String, transaction_id: String, userdevice_location: String,location: String, issuer: String, amount: Double)

	val input = ssc.socketTextStream("localhost", 9999)
	val lines = input.map(f => f.split("\n").map(f => f.split(",")))

	val transactions = lines.map(line => new Transaction(line(0)(0), line(0)(1), line(0)(2), line(0)(3), line(0)(4), line(0)(5), line(0)(6).toDouble))
