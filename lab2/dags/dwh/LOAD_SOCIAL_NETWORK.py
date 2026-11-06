"""CSV соцсети -> stg -> Data Vault (dds) -> аналитические витрины (cdm)"""

from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

from common.csv_loader import stage_csv
from common.model_task import run_model


MODELS_DIR = 'dwh/LOAD_SOCIAL_NETWORK'

SOURCES = {
    'people': ['id', 'name', 'registration_date', 'country',
               'date_of_birthday', 'phone', 'e-mail'],
    'groups': ['id', 'owner_id', 'group_name', 'created_date'],
    'chats': ['msg_id', 'msg_time', 'msg_from', 'msg_to',
              'text_message', 'msg_group_id'],
}

HUBS = ['h_people', 'h_groups', 'h_chats']
LINKS = ['l_chat_owners', 'l_person_chat', 'l_groups']
SATELLITES = ['s_person_info', 's_group_info', 's_chat_info']
MARTS = ['group_activity', 'person_activity', 'messages_monthly']


def model_task(name, schema):
    return PythonOperator(
        task_id=name,
        python_callable=run_model,
        op_kwargs={
            'model_path': f'{MODELS_DIR}/{name}.sql',
            'target_table': f'{schema}.{name}',
        },
        execution_timeout=timedelta(minutes=10),
    )


with DAG(
    dag_id='dwh.LOAD_SOCIAL_NETWORK',
    description='CSV соцсети -> stg -> Data Vault -> cdm',
    schedule='0 3 * * *',
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
        'stg',
        'dds',
        'cdm',
    ],
) as dag:

    with TaskGroup('stg') as stg:
        for source, header in SOURCES.items():
            PythonOperator(
                task_id=f'stage_{source}',
                python_callable=stage_csv,
                op_kwargs={
                    'source': source,
                    'header': header,
                },
                execution_timeout=timedelta(minutes=10),
            )

    with TaskGroup('dds_hubs') as hubs:
        for name in HUBS:
            model_task(name, 'dds')

    with TaskGroup('dds_links') as links:
        for name in LINKS:
            model_task(name, 'dds')

    with TaskGroup('dds_satellites') as satellites:
        for name in SATELLITES:
            model_task(name, 'dds')

    with TaskGroup('cdm') as cdm:
        for name in MARTS:
            model_task(name, 'cdm')

    stg >> hubs >> [links, satellites] >> cdm
