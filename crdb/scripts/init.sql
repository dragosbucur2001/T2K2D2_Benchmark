-- CockroachDB initialiser

drop database bd2 cascade;
create database bd2;

use bd2;

create table if not exists words (
	id int default unique_rowid() primary key,
	lemma string not null
);

create table if not exists geo_locations (
	id int default unique_rowid() primary key,
	x int not null,
	y int not null
);

create table if not exists genders (
	id int default unique_rowid() primary key,
	type string not null
);

create table if not exists authors (
	id int default unique_rowid() primary key,
	age int not null,
	id_gender int references genders(id)
);

create table if not exists documents (
	id int default unique_rowid() primary key,
	id_location int references geo_locations(id),
	date date not null,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null
);

create table if not exists documents_authors (
	id_document int references documents(id),
	id_author int references authors(id),
	primary key (id_document, id_author)
);

create table if not exists vocabulary (
	id_document int references documents(id),
	id_word int references words(id),
	count int not null, -- count + pos fields are not used
	tf float not null,

	primary key (id_document, id_word)
);

