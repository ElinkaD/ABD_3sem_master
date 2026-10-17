"""Создание wrk-таблицы и загрузка в неё CSV-файла."""

from contextlib import closing
from pathlib import Path

from airflow.providers.postgres.hooks.postgres import PostgresHook
from psycopg2 import sql

DATA = Path('/data')
MODELS = Path('/opt/airflow/models')


def _table(name: str):
    parts = name.split('.')
    if len(parts) != 2:
        raise ValueError(f'Table must have schema.table format: {name}')
    return sql.Identifier(parts[0], parts[1])


def load_csv_to_wrk(source, model_path, work_table, **_):
    """Пересоздаёт wrk-таблицу по модели и копирует в неё полный CSV."""
    path = DATA / f'{source}.csv'
    model = (MODELS / model_path).resolve()

    if not model.is_relative_to(MODELS):
        raise ValueError(f'Model path is outside {MODELS}: {model_path}')
    if not model.exists():
        raise FileNotFoundError(model)
    if not path.exists():
        raise FileNotFoundError(path)
    if path.stat().st_size == 0:
        raise ValueError(f'Empty file without a CSV header: {path.name}')

    hook = PostgresHook(postgres_conn_id='pg_dwh')
    with closing(hook.get_conn()) as conn:
        with conn, conn.cursor() as cur:
            cur.execute(model.read_text(encoding='utf-8'))
            with path.open('r', encoding='utf-8', newline='') as stream:
                copy_query = sql.SQL(
                    "COPY {} FROM STDIN "
                    "WITH (FORMAT CSV, HEADER MATCH, ENCODING 'UTF8')"
                ).format(_table(work_table))
                cur.copy_expert(copy_query.as_string(cur), stream)
