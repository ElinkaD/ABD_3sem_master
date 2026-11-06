"""Подключение к Vertica и журнал загрузок etl.load_runs"""

import logging
from contextlib import closing

import vertica_python
from airflow.hooks.base import BaseHook

log = logging.getLogger(__name__)


def connect():
    conn = BaseHook.get_connection('vertica_dwh')
    return vertica_python.connect(
        host=conn.host,
        port=conn.port,
        user=conn.login,
        password=conn.password,
        database=conn.schema,
    )


def run_audited(load, source, target_table, ti, **_):
    with closing(connect()) as conn:
        cur = conn.cursor()
        cur.execute(
            """INSERT INTO etl.load_runs
               (dag_id, task_id, attempt, source, target_table)
               VALUES (%s, %s, %s, %s, %s)""",
            (ti.dag_id, ti.task_id, ti.try_number, source, target_table),
        )
        cur.execute('SELECT LAST_INSERT_ID()')
        audit_id = cur.fetchone()[0]
        conn.commit()

        try:
            row_count, rejected_count = load(cur)
            cur.execute(
                """UPDATE etl.load_runs SET status = 'success', row_count = %s,
                   rejected_count = %s, finished_at = clock_timestamp()
                   WHERE id = %s""",
                (row_count, rejected_count, audit_id),
            )
            conn.commit()
        except Exception as exc:
            conn.rollback()
            cur.execute(
                """UPDATE etl.load_runs SET status = 'failed', error = %s,
                   finished_at = clock_timestamp() WHERE id = %s""",
                (str(exc)[:4000], audit_id),
            )
            conn.commit()
            raise

    log.info('Loaded %s: rows=%s rejected=%s', target_table, row_count, rejected_count)
