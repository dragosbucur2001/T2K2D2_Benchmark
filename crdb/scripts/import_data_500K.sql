-- CockroachDB importer

use bd2;

import into words (id, word) csv data
	('nodelocal://1/500K/documents_clean500K.json.words.csv');

import into geo_locations (id, x, y) csv data
	('nodelocal://1/500K/documents_clean500K.json.locations.csv');

import into genders (id, type) csv data
	('nodelocal://1/500K/documents_clean500K.json.genders.csv');

import into authors (id, id_gender, age) csv data
	('nodelocal://1/500K/documents_clean500K.json.authors.csv');

import into documents (
	id,
	id_location,
	lemma_text,
	clean_text,
	raw_text,
	date
) csv data ('nodelocal://1/500K/documents_clean500K.json.documents.csv');

import into documents_authors (
	id_document,
	id_author
) csv data ('nodelocal://1/500K/documents_clean500K.json.documents_authors.csv');

import into vocabulary (
	id_word,
	id_document,
	count,
	tf
) csv data ('nodelocal://1/500K/documents_clean500K.json.vocabulary.csv');

