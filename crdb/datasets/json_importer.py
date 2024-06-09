#!/usr/bin/env python3

import time
import sys
import pandas as pd
import pickle as pkl
from pathlib import Path
from argparse import ArgumentParser, RawTextHelpFormatter
import csv

import uuid


def load_data(json_file) -> pd.DataFrame:
    cache = Path(f"{json_file}.pkl")
    if cache.is_file():
        print("Using cache")
        with open(cache, "rb") as f:
            return pkl.load(f)

    with open(json_file) as f:
        print("Reading JSON")
        data = pd.read_json(f, lines=True)
        with open(cache, "wb") as f:
            print("Caching")
            pkl.dump(data, f)
            print("Cache Succesful")
        return data


def gen_id():
    return uuid.uuid4().int & (1 << 63) - 1


def write_db():
    # =========== LOCATIONS ===========
    location = entry["geoLocation"]
    location_key = (location[0], location[1])
    location_id = (
        locations_dict[location_key] if location_key in locations_dict else gen_id()
    )
    if location_key not in locations_dict:
        locations_dict[location_key] = location_id
        locations_csv.writerow([location_id, location[0], location[1]])
        locations_olap_csv.writerow([location_id, location[0], location[1]])

    # =========== GENDERS ===========
    gender_type = entry["gender"]
    gender_id = genders_dict.get(gender_type)
    if gender_id is None:
        gender_id = gen_id()
        genders_dict[gender_type] = gender_id
        genders_csv.writerow([gender_id, gender_type])

    # =========== AUTHORS ===========
    author_id = (
        entry["author"]
        if type(entry["author"]) == int
        else entry["author"]["$numberLong"]
    )
    if author_id not in author_dict:
        author_dict[author_id] = author_id
        authors_csv.writerow([author_id, gender_id, entry["age"]])
        authors_olap_csv.writerow([author_id, gender_type, entry["age"]])

    # =========== DATE ===========
    time = entry["date"]["$date"]
    time_id = date_dict.get(time)
    if time_id is None:
        time_id = gen_id()
        date_dict[time] = time_id
        date_olap_csv.writerow([time_id, time])

    # =========== DOCUMENTS ===========
    document_id = (
        entry["_id"] if type(entry["_id"]) == int else entry["_id"]["$numberLong"]
    )
    documents_csv.writerow(
        [
            document_id,
            location_id,
            entry["lemmaText"],
            entry["cleanText"],
            entry["rawText"],
            time,
        ]
    )
    documents_olap_csv.writerow(
        [document_id, entry["rawText"], entry["lemmaText"], entry["cleanText"]]
    )
    date_olap_csv.writerow([time_id, time])

    # =========== DOCUMENTS & AUTHORS ===========
    documents_authors_csv.writerow([document_id, author_id])

    # =========== WORDS & VOCABULARY ===========
    for word_meta in entry["words"]:
        word = word_meta["word"]
        count = word_meta["count"]
        tf = word_meta["tf"]

        word_id = words_dict.get(word)
        if word_id is None:
            word_id = gen_id()
            words_dict[word] = word_id
            words_csv.writerow([word_id, word])
            words_olap_csv.writerow([word_id, word])

        vocabulary_csv.writerow([word_id, document_id, count, tf])
        documents_facts_olap_csv.writerow(
            [document_id, word_id, location_id, author_id, time_id, count, tf]
        )


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__, formatter_class=RawTextHelpFormatter)
    parser.add_argument("json", help="Path to the JSON file")
    parser.add_argument("--refresh-csv", help="Recreate CSV files", action="store_true")

    opt = parser.parse_args()

    if Path(f"{opt.json}.db.documents.csv").exists() and not opt.refresh_csv:
        print("CSV already exist")
        exit(0)

    df = load_data(opt.json)
    if df is None:
        print("Failed to load data", file=sys.stderr)
        exit(1)

    print("=====================")
    print(df.columns)
    print("=====================")
    print(df.iloc[0])
    print("=====================")
    print(df.iloc[0]["words"])
    print("=====================")

    start_time = time.time()

    authors_csv = csv.writer(open(f"{opt.json}.db.authors.csv", "w"))
    documents_csv = csv.writer(open(f"{opt.json}.db.documents.csv", "w"))
    genders_csv = csv.writer(open(f"{opt.json}.db.genders.csv", "w"))
    locations_csv = csv.writer(open(f"{opt.json}.db.locations.csv", "w"))
    words_csv = csv.writer(open(f"{opt.json}.db.words.csv", "w"))
    vocabulary_csv = csv.writer(open(f"{opt.json}.db.vocabulary.csv", "w"))

    locations_olap_csv = csv.writer(open(f"{opt.json}.olap.locations.csv", "w"))
    authors_olap_csv = csv.writer(open(f"{opt.json}.olap.authors.csv", "w"))
    documents_olap_csv = csv.writer(open(f"{opt.json}.olap.documents.csv", "w"))
    words_olap_csv = csv.writer(open(f"{opt.json}.olap.words.csv", "w"))
    date_olap_csv = csv.writer(open(f"{opt.json}.olap.date.csv", "w"))
    documents_facts_olap_csv = csv.writer(
        open(f"{opt.json}.olap.documents_facts.csv", "w")
    )

    author_dict = {}
    documents_dict = {}
    genders_dict = {}
    locations_dict = {}
    words_dict = {}
    vocabulary_dict = {}
    date_dict = {}

    documents_authors_csv = csv.writer(
        open(f"{opt.json}.db.documents_authors.csv", "w")
    )
    documents_authors_dict = {}

    for idx, entry in df.iterrows():
        if idx % 10000 == 0:
            print(f"Processing entry {idx}, took {time.time() - start_time:.2f}s")

        write_db()
