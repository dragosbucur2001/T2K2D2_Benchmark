-- CockroachDB initialiser

create database if not exists bd2;

use bd2;

create table words (
	id int default unique_rowid() primary key,
	lemma string not null
);

create table documents (
	id int default unique_rowid() primary key,
	location geometry not null,
	date date not null,
	raw_text string not null,
	lemma_text string not null,
	clean_text string not null
);

create table vocabulary (
	document_id int references documents(id),
	word_id int references words(id),
	-- count int not null, -- count + pos fields are not used
	tf float not null,

	primary key (document_id, word_id)
);

create type gender as enum ('male', 'female');

create table authors (
	id int default unique_rowid() primary key,
	first_name string not null,
	last_name string not null,
	age int not null,
	gender gender not null
);


