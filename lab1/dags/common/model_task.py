from contextlib import closing
from pathlib import Path

from airflow.providers.postgres.hooks.postgres import PostgresHook


MODELS = Path('/opt/airflow/models')


def run_model(model_path: str, **_):
    """Выполняет SQL-модель и формирует данные в wrk-слое."""

    path = (MODELS / model_path).resolve()

    if not path.is_relative_to(MODELS):
        raise ValueError(f'Model path is outside {MODELS}: {model_path}')

    if not path.exists():
        raise FileNotFoundError(path)

    sql = path.read_text(encoding='utf-8')

    hook = PostgresHook(
        postgres_conn_id='pg_dwh',
    )

    with closing(hook.get_conn()) as conn:
        with conn.cursor() as cur:
            cur.execute(sql)

        conn.commit()
