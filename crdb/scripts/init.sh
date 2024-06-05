#!/bin/bash
cockroach sql --insecure --database=bd2 -f init.sql

echo "Created tables"

cockroach sql --insecure --database=bd2 -f import_data_500k.sql
