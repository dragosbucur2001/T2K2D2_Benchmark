-- CockroachDB initialiser

drop database if exists bd2 cascade;

create database bd2;

use bd2;

set cluster setting sql.defaults.distsql = always;
set cluster setting sql.defaults.experimental_distsql_planning = on;

-- SET CLUSTER SETTING sql.distsql.temp_storage.workmem = '256MiB';

create table if not exists words (
	id int default unique_rowid() primary key,
	word string not null,

	index (word)
);

create table if not exists geo_location (
	id int default unique_rowid() primary key,
	x int not null,
	y int not null,

	index (id, x) storing (y),
	index (y) storing (x)
);

create table if not exists genders (
	id int default unique_rowid() primary key,
	type string not null,

	index (type)
);

create table if not exists authors (
	id int default unique_rowid() primary key,
	age int not null,
	id_gender int references genders(id),

	index (id_gender)
);

create table if not exists documents (
	id int default unique_rowid() primary key,
	id_geo_loc int references geo_location(id),
	document_date date not null,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null,

	index (document_date) storing (id_geo_loc),
	index (id_geo_loc) storing (document_date)
);

create table if not exists documents_authors (
	id_document int references documents(id),
	id_author int references authors(id),

	primary key (id_document, id_author),
	index (id_author, id_document)
);

create table if not exists vocabulary (
	id_document int references documents(id),
	id_word int references words(id),
	count int not null, -- count + pos fields are not used
	tf decimal not null,

	primary key (id_document, id_word),
	index (id_word) storing (tf, count)
);

-- limit range size in order to create multiple ranges, maybe this helps the distsql planner

alter table words configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
alter table geo_location configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
alter table genders configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
alter table authors configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
alter table documents_authors configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
alter table vocabulary configure zone using range_min_bytes = 0, range_max_bytes = 67108864;
