"""Метаданные Airflow -> системные витрины расписаний и статусов задач"""

from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator

from common.airflow_metadata import stage_airflow_metadata
from common.model_task import run_model


MODELS_DIR = 'monitoring/LOAD_SYSTEM_MARTS'


with DAG(
    dag_id='monitoring.LOAD_SYSTEM_MARTS',
    description='Метаданные Airflow -> monitoring.dag_schedule_check, monitoring.task_status',
    schedule='*/15 * * * *',
    start_date=pendulum.datetime(2026, 11, 1, tz='UTC'),
    catchup=False,
    max_active_runs=1,
    is_paused_upon_creation=False,
    default_args={
        'retries': 1,
        'retry_delay': timedelta(seconds=30),
    },
    tags=[
        'lab2',
        'monitoring',
    ],
) as dag:

    task_1_stage = PythonOperator(
        task_id='stage_airflow_metadata',
        python_callable=stage_airflow_metadata,
        execution_timeout=timedelta(minutes=5),
    )

    task_2_schedules = PythonOperator(
        task_id='dag_schedule_check',
        python_callable=run_model,
        op_kwargs={
            'model_path': f'{MODELS_DIR}/dag_schedule_check.sql',
            'target_table': 'monitoring.dag_schedule_check',
        },
        execution_timeout=timedelta(minutes=5),
    )

    task_3_tasks = PythonOperator(
        task_id='task_status',
        python_callable=run_model,
        op_kwargs={
            'model_path': f'{MODELS_DIR}/task_status.sql',
            'target_table': 'monitoring.task_status',
        },
        execution_timeout=timedelta(minutes=5),
    )

    task_1_stage >> [task_2_schedules, task_3_tasks]
