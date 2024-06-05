#!/usr/bin/env python3

import time
import sys
import pandas as pd
import pickle as pkl
from pathlib import Path
from argparse import ArgumentParser, RawTextHelpFormatter

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


def import_to_db(json_file, csv_file):
    df = load_data(json_file)

    print(df.columns)
    for i in range(10):
        print("=====================")
        # print(df.iloc[i])
        print(df.iloc[i]["words"])


def gen_id():
    return uuid.uuid4().int & (1 << 63) - 1


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__, formatter_class=RawTextHelpFormatter)
    parser.add_argument("json", help="Path to the JSON file")
    parser.add_argument(
        "db",
        default="postgresql://root@127.0.0.1:26257/bd2?sslmode=disable",
        nargs="?",
        help="database connection string (default: value of the DATABASE_URL environment variable)",
    )

    opt = parser.parse_args()
    if opt.db is None:
        parser.error("database connection string not set")

    df = load_data(opt.json)
    if df is None:
        print("Failed to load data", file=sys.stderr)
        exit(1)

    # conn = psycopg.connect(
    #     opt.db,
    #     row_factory=namedtuple_row,
    # )
    #
    # if conn is None or conn.info.status != ConnStatus.OK:
    #     print("Failed to connect to the database", file=sys.stderr)
    #     exit(1)

    start_time = time.time()

    authors_csv = open(f"{opt.json}.authors.csv", "w")
    author_dict = {}

    documents_csv = open(f"{opt.json}.documents.csv", "w")
    documents_dict = {}

    genders_csv = open(f"{opt.json}.genders.csv", "w")
    genders_dict = {}

    locations_csv = open(f"{opt.json}.locations.csv", "w")
    locations_dict = {}

    words_csv = open(f"{opt.json}.words.csv", "w")
    words_dict = {}

    for idx, entry in df.iterrows():
        if idx % 10000 == 0:
            print(f"Processing entry {idx}, took {time.time() - start_time:.2f}s")

        author_id = (
            entry["author"]
            if type(entry["author"]) == int
            else entry["author"]["$numberLong"]
        )
        if author_id not in author_dict:
            author_dict[author_id] = ()
            authors_csv.write(f"{author_id},{entry['gender']},{entry['age']}\n")

        location = entry["geoLocation"]
        location_key = (location[0], location[1])
        location_id = (
            locations_dict[location_key] if location_key in locations_dict else gen_id()
        )
        if location_key not in locations_dict:
            locations_dict[location_key] = ()
            locations_csv.write(f"{gen_id()},{location[0]},{location[1]}\n")

    authors_csv.close()
    documents_csv.close()
    genders_csv.close()
    locations_csv.close()
    words_csv.close()

    # with conn.transaction():
    #     with conn.cursor() as cur:
    #         for idx, entry in df.iterrows():
    #             if idx % 1000 == 0:
    #                 print(
    #                     f"Processing entry {idx}, took {time.time() - start_time:.2f}s"
    #                 )
    #             # print((entry["author"]["$numberLong"], entry["gender"], entry["age"]))
    #             # get the result of the execute
    #             author = (
    #                 entry["author"]
    #                 if type(entry["author"]) == int
    #                 else entry["author"]["$numberLong"]
    #             )
    #             cur.execute(
    #                 "UPSERT INTO authors (id, gender, age) VALUES (%s, %s, %s) RETURNING *",
    #                 (author, entry["gender"], entry["age"]),
    #             )
