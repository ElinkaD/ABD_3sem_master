#!/bin/bash
set -eu

ADMINTOOLS=/opt/vertica/bin/admintools

if grep -q "^\[Database:${VERTICA_DB}\]" /opt/vertica/config/admintools.conf 2>/dev/null; then
    "$ADMINTOOLS" -t start_db -d "$VERTICA_DB" -p "$VERTICA_PASSWORD" --force
else
    "$ADMINTOOLS" -t create_db -d "$VERTICA_DB" -p "$VERTICA_PASSWORD" --hosts=localhost
fi

stop_db() {
    "$ADMINTOOLS" -t stop_db -d "$VERTICA_DB" -p "$VERTICA_PASSWORD" -F || true
    exit 0
}
trap stop_db TERM INT

sleep infinity &
wait
