"""Общий перенос подготовленного wrk-слоя в целевую таблицу."""

import logging
from contextlib import closing
from datetime import datetime, timezone

from airflow.providers.postgres.hooks.postgres import PostgresHook
from psycopg2 import sql

log = logging.getLogger(__name__)


def _table(name: str):
    parts = name.split('.')
    if len(parts) != 2:
        raise ValueError(f'Table must have schema.table format: {name}')
    return sql.Identifier(parts[0], parts[1])


def _columns(names):
    return sql.SQL(', ').join(sql.Identifier(name) for name in names)


def load(
    work_table,
    target_table,
    target_columns,
    source_name,
    lock_id,
    work_columns=None,
    dag_run=None,
    ti=None,
    **_,
):
    """Заменяет целевую таблицу данными wrk и фиксирует результат в журнале."""
    if work_columns is not None and len(work_columns) != len(target_columns):
        raise ValueError('work_columns and target_columns must have equal length')

    hook = PostgresHook(postgres_conn_id='pg_dwh')
    audit_id = None
    try:
        with closing(hook.get_conn()) as conn:
            with conn, conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO etl.load_runs
                       (dag_id, attempt, source_file, target_table)
                       VALUES (%s, %s, %s, %s) RETURNING id""",
                    (dag_run.dag_id, ti.try_number, source_name, target_table),
                )
                audit_id = cur.fetchone()[0]

            with conn, conn.cursor() as cur:
                cur.execute("SET LOCAL lock_timeout = '15s'")
                cur.execute("SET LOCAL statement_timeout = '5min'")
                cur.execute('SELECT pg_advisory_xact_lock(20261016, %s)', (lock_id,))
                loaded_at = datetime.now(timezone.utc)

                cur.execute(
                    sql.SQL('SELECT count(*) FROM {}').format(_table(work_table))
                )
                count = cur.fetchone()[0]
                cur.execute(sql.SQL('TRUNCATE TABLE {}').format(_table(target_table)))

                selected = sql.SQL('*') if work_columns is None else _columns(work_columns)
                insert_query = sql.SQL(
                    'INSERT INTO {} ({}, {}) SELECT {}, %s FROM {}'
                ).format(
                    _table(target_table),
                    _columns(target_columns),
                    sql.Identifier('loaded_at'),
                    selected,
                    _table(work_table),
                )
                cur.execute(insert_query, (loaded_at,))

                cur.execute(
                    sql.SQL('SELECT count(*) FROM {}').format(_table(target_table))
                )
                if cur.fetchone()[0] != count:
                    raise ValueError('Work and target row counts differ')

                cur.execute(
                    """UPDATE etl.load_runs SET status = 'success', row_count = %s,
                       loaded_at = %s, finished_at = clock_timestamp() WHERE id = %s""",
                    (count, loaded_at, audit_id),
                )
        log.info('Committed work=%s target=%s rows=%s', work_table, target_table, count)
    except Exception as exc:
        if audit_id is not None:
            try:
                with closing(hook.get_conn()) as conn, conn, conn.cursor() as cur:
                    cur.execute(
                        """UPDATE etl.load_runs SET status = 'failed', error = %s,
                           finished_at = clock_timestamp() WHERE id = %s""",
                        (str(exc)[:4000], audit_id),
                    )
            except Exception:
                log.exception('Could not record failure in etl.load_runs')
        raise
