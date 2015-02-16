use datastax_transactions;

truncate credit_card_transactions_by_user;
truncate credit_card_transactions_by_issuer_date;

drop keyspace datastax_transactions;
	
