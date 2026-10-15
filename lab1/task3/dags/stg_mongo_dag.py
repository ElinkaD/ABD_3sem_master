import json
from datetime import datetime

import pendulum
from airflow.decorators import dag, task
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from bson import json_util
from pymongo import MongoClient

COLLECTIONS = ['clients', 'restaurants', 'orders']

GET_LAST_TS = """
    SELECT settings->>'last_loaded_ts'
    FROM stg.settings
    WHERE settings_key = %s
"""

UPSERT_DOCUMENT = """
    INSERT INTO stg.mongo_{collection} (object_id, object_value, update_ts)
    VALUES (%s, %s, %s)
    ON CONFLICT (object_id) DO UPDATE
    SET object_value = EXCLUDED.object_value,
        update_ts = EXCLUDED.update_ts
"""

SAVE_SETTINGS = """
    INSERT INTO stg.settings (settings_key, settings)
    VALUES (%s, %s)
    ON CONFLICT (settings_key) DO UPDATE
    SET settings = EXCLUDED.settings
"""


@dag(
    schedule='*/15 * * * *',
    start_date=pendulum.datetime(2026, 10, 1, tz='UTC'),
    catchup=False,
    is_paused_upon_creation=False,
    tags=['task3'],
)
def stg_mongo():
    @task
    def load_collection(collection: str):
        settings_key = f'mongo_{collection}_to_stg'
        mongo = MongoClient(Variable.get('MONGO_URI')).get_default_database()
        dwh = PostgresHook('pg_dwh')

        with dwh.get_conn() as conn, conn.cursor() as cur:
            cur.execute(GET_LAST_TS, (settings_key,))
            row = cur.fetchone()
            last_ts = datetime.fromisoformat(row[0]) if row else datetime.min

            docs = list(
                mongo[collection]
                .find({'update_time': {'$gt': last_ts}})
                .sort('update_time')
            )

            for doc in docs:
                cur.execute(
                    UPSERT_DOCUMENT.format(collection=collection),
                    (str(doc['_id']),
                     json_util.dumps(doc, ensure_ascii=False),
                     doc['update_time']),
                )

            if docs:
                last_ts = docs[-1]['update_time'].isoformat()
                settings = json.dumps({'last_loaded_ts': last_ts})
                cur.execute(SAVE_SETTINGS, (settings_key, settings))

    for collection in COLLECTIONS:
        load_collection.override(task_id=f'load_{collection}')(collection)


stg_mongo()
