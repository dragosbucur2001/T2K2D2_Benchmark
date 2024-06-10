-- CockroachDB initialiser

drop database if exists bd2 cascade;

create database bd2;

use bd2;

set cluster setting sql.defaults.distsql = always; 
SET CLUSTER SETTING sql.distsql.temp_storage.workmem = '256MiB';

create table if not exists word_dimension (
	id_word int default unique_rowid() primary key,
	word string not null
);

create table if not exists location_dimension (
	id_location int default unique_rowid() primary key,
	x int not null,
	y int not null
);

create type gender as enum ('male', 'female');

create table if not exists author_dimension (
	id_author int default unique_rowid() primary key,
	age int not null,
	gender gender not null
);

create table if not exists document_dimension (
	id_document int default unique_rowid() primary key,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null
);

create table if not exists time_dimension (
	id_time int default unique_rowid() primary key,
	full_date date not null
);

create table if not exists document_facts (
	id_document int references document_dimension(id_document),
	id_word int references word_dimension(id_word),
	id_location int references location_dimension(id_location),
	id_author int references author_dimension(id_author),
	id_time int references time_dimension(id_time),
	count int not null,
	tf decimal not null,

	primary key (id_document, id_author, id_word, id_location, id_time)
);

