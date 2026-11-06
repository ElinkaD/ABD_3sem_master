"""Загрузка CSV-файлов соцсети в stg через COPY"""

import csv
import io
from pathlib import Path

from common.vertica import run_audited

DATA = Path('/data')
COLUMNS = {'e-mail': 'email'}


def normalize_csv(raw: bytes, header: list[str]) -> str:
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        text = raw.decode('cp1251')

    rows = list(csv.reader(io.StringIO(text)))
    if not rows or rows[0] != header:
        raise ValueError(f'Unexpected CSV header: {rows[0] if rows else None}')

    out = io.StringIO()
    writer = csv.writer(out, doublequote=False, escapechar='\\', lineterminator='\n')
    for row in rows[1:]:
        if len(row) == 1 and len(header) > 1:
            row = next(csv.reader([row[0]]))
        if len(row) != len(header):
            raise ValueError(f'Row has {len(row)} fields instead of {len(header)}: {row}')
        writer.writerow(row)
    return out.getvalue()


def stage_csv(source, header, **context):
    path = DATA / f'{source}.csv'
    target_table = f'stg.{source}'
    columns = [COLUMNS.get(c, c) for c in header]
    data = normalize_csv(path.read_bytes(), header)

    def load(cur):
        cur.execute(f'DROP TABLE IF EXISTS {target_table}_rej')
        cur.execute(f'DELETE FROM {target_table}')
        cur.copy(
            f"""COPY {target_table} ({', '.join(columns)})
                FROM STDIN DELIMITER ',' ENCLOSED BY '"'
                REJECTED DATA AS TABLE {target_table}_rej""",
            data,
        )
        cur.execute('SELECT GET_NUM_ACCEPTED_ROWS(), GET_NUM_REJECTED_ROWS()')
        return cur.fetchone()

    run_audited(load, path.name, target_table, **context)
