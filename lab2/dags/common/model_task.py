"""Выполнение SQL-моделей в Vertica"""

import re
from pathlib import Path

from common.vertica import run_audited

MODELS = Path('/opt/airflow/models')


def read_statements(model_path: str) -> list[str]:
    text = (MODELS / model_path).read_text(encoding='utf-8')
    return [s.strip() for s in re.split(r';\s*(?:\n|$)', text) if s.strip()]


def run_model(model_path, target_table, **context):
    statements = read_statements(model_path)

    def load(cur):
        inserted = 0
        for statement in statements:
            cur.execute(statement)
            if statement.upper().startswith('INSERT'):
                inserted += cur.fetchone()[0]
        return inserted, None

    run_audited(load, model_path, target_table, **context)
