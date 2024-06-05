-- CockroachDB initialiser

create database if not exists bd2;

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

create type if not exists gender as enum ('male', 'female');

create table if not exists authors (
	id int default unique_rowid() primary key,
	age int not null,
	gender gender not null
);

create table if not exists documents (
	id int default unique_rowid() primary key,
	location_id int references geo_locations(id),
	author_id int references authors(id),
	date date not null,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null
);

create table if not exists vocabulary (
	document_id int references documents(id),
	word_id int references words(id),
	count int not null, -- count + pos fields are not used
	tf float not null,

	primary key (document_id, word_id)
);

