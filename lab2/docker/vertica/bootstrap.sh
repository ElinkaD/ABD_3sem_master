#!/bin/bash
set -eu

vsql() {
    /opt/vertica/bin/vsql -h "$VERTICA_HOST" -d "$VERTICA_DB" \
        -U "$VERTICA_USER" -w "$VERTICA_PASSWORD" -v ON_ERROR_STOP=1 "$@"
}

for ddl in /schemas/etl/*.sql /schemas/stg/*.sql /schemas/dds/*.sql \
           /schemas/cdm/*.sql /schemas/monitoring/*.sql; do
    vsql -f "$ddl"
done

for seed in /seeds/*.sql; do
    vsql -f "$seed"
done
