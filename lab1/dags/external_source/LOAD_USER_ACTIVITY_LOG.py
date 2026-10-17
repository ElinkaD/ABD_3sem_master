"""Задание 2: ручная загрузка user_activity_log.csv."""

from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator

from common.csv_loader import load_csv_to_wrk
from common.load_task import load


SOURCE = 'user_activity_log'
MODEL_PATH = 'external_source/LOAD_USER_ACTIVITY_LOG/wrk_user_activity_log_1.sql'
WORK_TABLE = 'wrk.user_activity_log'
TARGET_TABLE = 'external_source.user_activity_log'
WORK_COLUMNS = ['date_time', 'customer_id']
TARGET_COLUMNS = ['date_time', 'customer_id']


with DAG(
    dag_id='external_source.LOAD_USER_ACTIVITY_LOG',
    description='CSV -> external_source.user_activity_log',
    schedule=None,
    start_date=pendulum.datetime(2026, 10, 1, tz='UTC'),
    catchup=False,
    max_active_runs=1,
    is_paused_upon_creation=False,
    default_args={
        'retries': 1,
        'retry_delay': timedelta(seconds=30),
    },
    tags=[
        'lab1',
        'task2',
        'external_source',
    ],
) as dag:

    task_1_stage = PythonOperator(
        task_id='stage_csv',
        python_callable=load_csv_to_wrk,
        op_kwargs={
            'source': SOURCE,
            'model_path': MODEL_PATH,
            'work_table': WORK_TABLE,
        },
        execution_timeout=timedelta(minutes=10),
        do_xcom_push=False,
    )

    task_2_load = PythonOperator(
        task_id='load',
        python_callable=load,
        op_kwargs={
            'work_table': WORK_TABLE,
            'target_table': TARGET_TABLE,
            'work_columns': WORK_COLUMNS,
            'target_columns': TARGET_COLUMNS,
            'source_name': f'{SOURCE}.csv',
            'lock_id': 2,
        },
        execution_timeout=timedelta(minutes=10),
        do_xcom_push=False,
    )

    task_1_stage >> task_2_load
