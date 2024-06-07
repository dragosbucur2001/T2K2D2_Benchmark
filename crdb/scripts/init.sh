#!/bin/bash


cockroach sql --insecure -f ./init.sql

echo "Created tables"

cockroach sql --insecure -f ./import_data_500k.sql
