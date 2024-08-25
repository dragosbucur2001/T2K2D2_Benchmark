-- CockroachDB importer

use bd2;

import into word_dimension (id_word, word) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.olap.words.csv');

import into location_dimension (id_location, x, y) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.olap.locations.csv');

import into author_dimension (id_author, gender, age) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.olap.authors.csv');

import into document_dimension (
	id_document,
	lemma_text,
	clean_text,
	raw_text
) csv data ('nodelocal://1/2000K/documents_clean2000K.json.olap.documents.csv');

import into time_dimension (id_time, full_date) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.olap.date.csv');

import into document_facts (
	id_document,
	id_word,
	id_location,
	id_author,
	id_time,
	count,
	tf
) csv data ('nodelocal://1/2000K/documents_clean2000K.json.olap.document_facts.csv');

