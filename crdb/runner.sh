#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -d DISTRIBUTED -t TYPE -m MODEL -s SIZE -h HEURISTIC"
  echo "  DISTRIBUTED: either 'distributed' or 'single'"
  echo "  TYPE: either 'Documents' or 'Keywords'"
  echo "  MODEL: either 'db' or 'olap'"
  echo "  SIZE: either '500K', '1000K', '1500K', '2000K', '2500K'"
  echo "  HEURISTIC: either 'Okapi' or 'TFIDF'"
  exit 1
}

# Parse command-line arguments
while getopts "d:t:m:s:h:" opt; do
  case ${opt} in
    d )
      DISTRIBUTED=$OPTARG
      ;;
    t )
      TYPE=$OPTARG
      ;;
    m )
      MODEL=$OPTARG
      ;;
    s )
      SIZE=$OPTARG
      ;;
    h )
      HEURISTIC=$OPTARG
      ;;
    \? )
      usage
      ;;
  esac
done

if [ -z "$DISTRIBUTED" ] || [ -z "$TYPE" ] || [ -z "$MODEL" ] || [ -z "$SIZE" ] || [ -z "$HEURISTIC" ] ; then
  usage
fi

if [[ "$DISTRIBUTED" != "distributed" && "$DISTRIBUTED" != "single" ]]; then
  echo "Invalid DISTRIBUTED value"
  usage
fi

if [[ "$TYPE" != "documents" && "$TYPE" != "keywords" ]]; then
  echo "Invalid TYPE value"
  usage
fi

if [[ "$MODEL" != "db" && "$MODEL" != "olap" ]]; then
  echo "Invalid MODEL value"
  usage
fi

if [[ "$SIZE" != "500K" && "$SIZE" != "1000K" && "$SIZE" != "1500K" && "$SIZE" != "2000K" && "$SIZE" != "2500K" ]]; then
  echo "Invalid SIZE value"
  usage
fi

if [[ "$HEURISTIC" != "Okapi" && "$HEURISTIC" != "TFIDF" ]]; then
  echo "Invalid HEURISTIC value"
  usage
fi

echo "Running script with the following parameters:"
echo "  DISTRIBUTED: $DISTRIBUTED"
echo "  TYPE: $TYPE"
echo "  MODEL: $MODEL"
echo "  SIZE: $SIZE"
echo "  HEURISTIC: $HEURISTIC"

export DISTRIBUTED
export TYPE
export MODEL
export SIZE
export HEURISTIC

./datasets/json_importer.py ./datasets/$SIZE/documents_clean$SIZE.json
# ./datasets/json_importer.py ./datasets/500k/documents_clean500K.json
docker compose up -d

CONTAINER_NAME="crdb-single-${TYPE}-${MODEL}-${SIZE}-${HEURISTIC}"
echo $CONTAINER_NAME

echo "SLEEPING"
sleep 5

echo "CREATING TABLES"
docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./scripts/init.sql"

echo "IMPORTING DATA"
docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./scripts/import_data_$SIZE.sql"

echo "CLEANUP"
docker compose down
