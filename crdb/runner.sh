#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -d DISTRIBUTED -t TYPE -m MODEL -s SIZE -h HEURISTIC [-b]"
  echo "  DISTRIBUTED: either 'distributed' or 'single'"
  echo "  MODEL: either 'DB' or 'OLAP'"
  echo "  SIZE: either '500K', '1000K', '1500K', '2000K', '2500K'"
  echo "  TYPE: either 'Documents' or 'Keywords'"
  echo "  HEURISTIC: either 'Okapi' or 'TFIDF'"
  echo "  -b: flag, if present will run benchmarks, otherwise just init container"
  exit 1
}

# Parse command-line arguments
while getopts "d:t:m:s:h:b" opt; do
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
    b )
      BENCHMARK=true
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

if [[ "$TYPE" != "Documents" && "$TYPE" != "Keywords" ]]; then
  echo "Invalid TYPE value"
  usage
fi

if [[ "$MODEL" != "DB" && "$MODEL" != "OLAP" ]]; then
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

echo
echo "======== CREATING THE DATASET ========="
./datasets/json_importer.py ./datasets/$SIZE/documents_clean$SIZE.json
# ./datasets/json_importer.py ./datasets/500k/documents_clean500K.json

echo
echo "======== DOCKER UP ========="
docker compose -f "docker-compose-$DISTRIBUTED.yml" up -d --wait

CONTAINER_NAME=""
HOST=""
HOST_CLUSTER=""

if [ "$DISTRIBUTED" == "distributed" ]; then
  CONTAINER_NAME="crdb-distributed-1-$TYPE-$MODEL-$SIZE-$HEURISTIC"
  HOST="--host=crdb1:26257"
  HOST_CLUSTER="--host=crdb1:26357"

  echo "======== INITIALIZING CLUSTER ========="
  docker exec -t $CONTAINER_NAME bash -c "cockroach init --insecure $HOST_CLUSTER"
  sleep 3
else
  CONTAINER_NAME="crdb-single-$TYPE-$MODEL-$SIZE-$HEURISTIC"
fi
echo
echo "======== CONTAINER NAME ========"
echo $CONTAINER_NAME

# echo
# echo "======== SLEEPING ========="
# sleep 5

echo
echo "======== CREATING TABLES ========="
echo docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./scripts/init_$MODEL.sql $HOST"
docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./scripts/init_$MODEL.sql $HOST"

echo
echo "======== IMPORTING DATA ========="
docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./scripts/$MODEL/import_data_$SIZE.sql $HOST"

if [ -z "$BENCHMARK" ] ; then
  exit
fi

echo "======== RUNNING QUERIES ========="

COUNTER=0
for f in "./queries/TopK_$TYPE/$MODEL"_"$HEURISTIC/"*.sql; do
  DIR_NAME="./results/$DISTRIBUTED"_"$SIZE/TopK_$TYPE/$MODEL"_"$HEURISTIC"
  mkdir -p $DIR_NAME

  FILENAME=$(basename "$f")
  OUTPUT_FILE="$DIR_NAME/$FILENAME.txt"
  rm -f $OUTPUT_FILE

  COUNTER=$((COUNTER+1))
  if [ $COUNTER -eq 1 ]; then
    echo
    echo "========== WARMUP =========="
    docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure --database=bd2 -f $f $HOST"
    docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure --database=bd2 -f $f $HOST"
    docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure --database=bd2 -f $f $HOST"
  fi

  echo
  echo "========== RUNNING $f =========="
  for i in {1..10}; do
    echo "RUNNING $i"
    echo -e "\n\n================== RUNNING $i ================\n\n" >> $OUTPUT_FILE

    docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure --database=bd2 -f $f $HOST" &>> $OUTPUT_FILE
  done
  echo -e "\n\n"
  # docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f $f"
done
# docker exec -t $CONTAINER_NAME bash -c "cockroach sql --insecure -f ./queries/TopK_$TYPE/$MODEL_$HEURISTIC/.sql"

echo
echo "========== CLEANUP =========="
docker compose -f "docker-compose-$DISTRIBUTED.yml" down
