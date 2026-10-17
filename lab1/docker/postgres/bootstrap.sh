#!/bin/sh
# Выполняется отдельным сервисом после готовности PostgreSQL.
set -eu

psql -X -v ON_ERROR_STOP=1 -d postgres <<'SQL'
SELECT 'CREATE DATABASE source'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'source')\gexec
SQL

# Старые задания содержат DROP/CREATE и тестовые INSERT: только при первом
# создании соответствующего набора таблиц, без перезаписи существующих данных.
if [ "$(psql -X -Atc "SELECT to_regclass('public.craft_market_orders') IS NULL")" = t ]; then
    psql -X -v ON_ERROR_STOP=1 -1 -f /schemas/public/01_craft_market.sql -f /seeds/craft_market.sql
fi
if [ "$(psql -X -d source -Atc "SELECT to_regclass('public.logs') IS NULL")" = t ]; then
    psql -X -d source -v ON_ERROR_STOP=1 -1 \
        -f /schemas/source/01_tables.sql \
        -f /schemas/source/02_logs_triggers.sql \
        -f /seeds/source.sql
fi
if [ "$(psql -X -Atc "SELECT to_regclass('stg.settings') IS NULL")" = t ]; then
    psql -X -v ON_ERROR_STOP=1 -1 -f /schemas/stg/01_tables.sql
fi
for ddl in /schemas/etl/*.sql /schemas/external_source/*.sql /schemas/wrk/*.sql; do
    psql -X -v ON_ERROR_STOP=1 -1 -f "$ddl"
done
psql -X -v ON_ERROR_STOP=1 -1 -f /schemas/public/02_customer_report.sql
