-- CockroachDB importer

use bd2;

import into words (id, lemma) csv data
	('nodelocal://1/documents_clean500K.json.words.csv');

import into geo_locations (id, x, y) csv data
	('nodelocal://1/documents_clean500K.json.locations.csv');

import into authors (id, gender, age) csv data
	('nodelocal://1/documents_clean500K.json.authors.csv');

import into documents (
	id,
	author_id,
	location_id,
	lemma_text,
	clean_text,
	raw_text,
	date
) csv data ('nodelocal://1/documents_clean500K.json.documents.csv');

import into vocabulary (
	word_id,
	document_id,
	count,
	tf
) csv data ('nodelocal://1/documents_clean500K.json.vocabulary.csv');

