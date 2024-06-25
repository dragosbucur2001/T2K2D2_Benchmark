-- CockroachDB initialiser

drop database if exists bd2 cascade;

create database bd2;

use bd2;

set cluster setting sql.defaults.distsql = always;

-- set cluster setting sql.defaults.experimental_distsql_planning = on;
-- SET CLUSTER SETTING sql.distsql.temp_storage.workmem = '256MiB';

create table if not exists words (
	id int default unique_rowid() primary key,
	word string not null,
);

create table if not exists geo_location (
	id int default unique_rowid() primary key,
	x int not null,
	y int not null,
);

create table if not exists genders (
	id int default unique_rowid() primary key,
	type string not null,
);

create table if not exists authors (
	id int default unique_rowid() primary key,
	age int not null,
	id_gender int references genders(id),
);

create table if not exists documents (
	id int default unique_rowid() primary key,
	id_geo_loc int references geo_location(id),
	document_date date not null,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null,
);

create table if not exists documents_authors (
	id_document int references documents(id),
	id_author int references authors(id),

	primary key (id_document, id_author),
);

create table if not exists vocabulary (
	id_document int references documents(id),
	id_word int references words(id),
	count int not null,
	tf decimal not null,

	primary key (id_document, id_word),
);

