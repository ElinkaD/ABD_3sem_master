"""Задание 1: ручное заполнение витрины по заказчикам."""

from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator

from common.model_task import run_model
from common.load_task import load


MODEL_PATH = 'public/LOAD_CUSTOMER_REPORT/wrk_customer_report_1.sql'
WORK_TABLE = 'wrk.customer_report'
TARGET_TABLE = 'public.customer_report'
TARGET_COLUMNS = [
    'id', 'customer_id', 'customer_name', 'customer_address',
    'customer_birthday', 'customer_email', 'customer_money',
    'platform_money', 'count_order', 'avg_price_order',
    'median_time_order_completed', 'product_type', 'craftsman_id',
    'count_order_created', 'count_order_in_progress',
    'count_order_delivery', 'count_order_done', 'count_order_not_done',
    'report_period',
]


with DAG(
    dag_id='public.LOAD_CUSTOMER_REPORT',
    description='Модель магазина -> public.customer_report',
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
        'task1',
        'public',
    ],
) as dag:

    task_1_model = PythonOperator(
        task_id='model',
        python_callable=run_model,
        op_kwargs={
            'model_path': MODEL_PATH,
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
            'target_columns': TARGET_COLUMNS,
            'source_name': MODEL_PATH,
            'lock_id': 10,
        },
        execution_timeout=timedelta(minutes=10),
        do_xcom_push=False,
    )

    task_1_model >> task_2_load
