create keyspace if not exists datastax_transactions WITH replication = {'class': 'NetworkTopologyStrategy', 'Analytics': 1};

use datastax_transactions; 
 
CREATE TABLE if not exists credit_card_transactions_by_user (
 credit_card_no text,
 transaction_time timestamp,
 transaction_id text, 
 amount double,
 userdevice_location text,
 PRIMARY KEY (credit_card_no, transaction_time)
) WITH CLUSTERING ORDER BY (transaction_time DESC);

CREATE TABLE if not exists credit_card_transactions_by_issuer_date (
 issuer text,
 date text, 
 transaction_id text,
 credit_card_no text,
 items map<text, double>,
 transaction_time timestamp,
 location text,
 amount double,
 PRIMARY KEY ((issuer, date), transaction_id)
) WITH CLUSTERING ORDER BY (transaction_id DESC);

truncate credit_card_transactions_by_user;
truncate credit_card_transactions_by_issuer_date;
