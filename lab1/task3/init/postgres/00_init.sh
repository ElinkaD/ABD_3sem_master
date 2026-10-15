#!/bin/bash
# Создаёт базы source и dwh и выполняет в них SQL-скрипты из /sql/source и /sql/dwh
set -e

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres <<-EOSQL
    CREATE DATABASE source;
    CREATE DATABASE dwh;
EOSQL

for f in /sql/source/*.sql; do
    echo "source: $f"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d source -f "$f"
done

for f in /sql/dwh/*.sql; do
    echo "dwh: $f"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d dwh -f "$f"
done
