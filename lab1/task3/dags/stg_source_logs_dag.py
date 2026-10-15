import json

import pendulum
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook

SETTINGS_KEY = 'source_logs_to_stg'

GET_LAST_ID = """
    SELECT settings->>'last_loaded_id'
    FROM stg.settings
    WHERE settings_key = %s
"""

GET_NEW_LOGS = """
    SELECT id, update_ts, object_type, object_id, operation, payload
    FROM logs
    WHERE id > %s
    ORDER BY id
"""

INSERT_LOG = """
    INSERT INTO stg.pg_logs
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (id) DO NOTHING
"""

SAVE_SETTINGS = """
    INSERT INTO stg.settings (settings_key, settings)
    VALUES (%s, %s)
    ON CONFLICT (settings_key) DO UPDATE
    SET settings = EXCLUDED.settings
"""


def apply_log(cur, object_type, object_id, operation, payload):
    table = f'stg.pg_{object_type}'
    key = f'{object_type}_id'

    if operation == 'DELETE':
        cur.execute(f'DELETE FROM {table} WHERE {key} = %s', (object_id,))
        return

    columns = list(payload)
    names = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))
    updates = ', '.join(f'{c} = EXCLUDED.{c}' for c in columns)
    cur.execute(
        f"""
            INSERT INTO {table} ({names})
            VALUES ({placeholders})
            ON CONFLICT ({key}) DO UPDATE
            SET {updates}
        """,
        [payload[c] for c in columns],
    )


@dag(
    schedule='*/15 * * * *',
    start_date=pendulum.datetime(2026, 10, 1, tz='UTC'),
    catchup=False,
    is_paused_upon_creation=False,
    tags=['task3'],
)
def stg_source_logs():
    @task
    def load_logs():
        source = PostgresHook('pg_source')
        dwh = PostgresHook('pg_dwh')

        with dwh.get_conn() as conn, conn.cursor() as cur:
            cur.execute(GET_LAST_ID, (SETTINGS_KEY,))
            row = cur.fetchone()
            last_id = int(row[0]) if row else 0

            logs = source.get_records(GET_NEW_LOGS, parameters=(last_id,))

            for log_id, ts, obj_type, obj_id, operation, payload in logs:
                cur.execute(
                    INSERT_LOG,
                    (log_id, ts, obj_type, obj_id, operation,
                     json.dumps(payload)),
                )
                apply_log(cur, obj_type, obj_id, operation, payload)

            if logs:
                settings = json.dumps({'last_loaded_id': logs[-1][0]})
                cur.execute(SAVE_SETTINGS, (SETTINGS_KEY, settings))

    load_logs()


stg_source_logs()
