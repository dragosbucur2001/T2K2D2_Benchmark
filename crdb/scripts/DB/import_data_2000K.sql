-- CockroachDB importer

use bd2;

import into words (id, word) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.db.words.csv');

import into geo_location (id, x, y) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.db.locations.csv');

import into genders (id, type) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.db.genders.csv');

import into authors (id, id_gender, age) csv data
	('nodelocal://1/2000K/documents_clean2000K.json.db.authors.csv');

import into documents (
	id,
	id_geo_loc,
	lemma_text,
	clean_text,
	raw_text,
	document_date
) csv data ('nodelocal://1/2000K/documents_clean2000K.json.db.documents.csv');

import into documents_authors (
	id_document,
	id_author
) csv data ('nodelocal://1/2000K/documents_clean2000K.json.db.documents_authors.csv');

import into vocabulary (
	id_word,
	id_document,
	count,
	tf
) csv data ('nodelocal://1/2000K/documents_clean2000K.json.db.vocabulary.csv');

