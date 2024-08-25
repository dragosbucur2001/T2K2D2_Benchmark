#!/bin/bash

# Usage: ./runner.sh -d DISTRIBUTED -t TYPE -m MODEL -s SIZE -h HEURISTIC [-b]
#  DISTRIBUTED: either 'distributed' or 'single'
#  MODEL: either 'DB' or 'OLAP'
#  SIZE: either '500K', '1000K', '1500K', '2000K', '2500K'
#  TYPE: either 'Documents' or 'Keywords'
#  HEURISTIC: either 'Okapi' or 'TFIDF'
#  -b: flag, if present will run benchmarks, otherwise just init container

# need to repeat olap 2000k
#
DISTRIBUTED=("distributed" "single")
MODEL=("OLAP")
SIZE=("2000K")
# MODEL=("DB" "OLAP")
# SIZE=("500K" "2000K")
# SIZE=("2500K")
# SIZE=("1000K" "1500K")
TYPE=("Documents" "Keywords")
HEURISTIC=("Okapi" "TFIDF")
echo "Running benchmarks for all combinations of DISTRIBUTED, MODEL, SIZE, TYPE, HEURISTIC"

for distributed_it in "${DISTRIBUTED[@]}"; do
  for model_it in "${MODEL[@]}"; do
    for size_it in "${SIZE[@]}"; do
      for type_it in "${TYPE[@]}"; do
        for heuristic_it in "${HEURISTIC[@]}"; do
          echo "Running command with DISTRIBUTED=$distributed_it, MODEL=$model_it, SIZE=$size_it, TYPE=$type_it, HEURISTIC=$heuristic_it"
          ./runner.sh -d "$distributed_it" -m "$model_it" -s "$size_it" -t "$type_it" -h "$heuristic_it" -b
        done
      done
    done
  done
done

# ./queries/TopK_Documents/DB_TFIDF/Q4_3w_female.sql
# single 2500k
#========== RUNNING ./queries/TopK_Keywords/DB_Okapi/Q2_female.sql ==========
#2500K
#single
#until ========== RUNNING ./queries/TopK_Keywords/DB_Okapi/Q2_male.sql ==========



