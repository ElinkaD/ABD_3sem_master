"""Снимок метаданных Airflow (DAG-и и запуски задач) в stg"""

from datetime import datetime, timedelta, timezone

from airflow.models import DagModel, DagRun, TaskInstance
from airflow.models.serialized_dag import SerializedDagModel
from airflow.utils.session import create_session
from croniter import croniter

from common.vertica import run_audited

HISTORY_DAYS = 30


def _dag_rows(session, snapshot_at):
    rows = []
    for dag in session.query(DagModel):
        schedule = str(dag.schedule_interval) if dag.schedule_interval else None
        serialized = SerializedDagModel.get(dag.dag_id, session=session)
        task_count = len(serialized.dag.task_ids) if serialized else None
        rows.append((
            dag.dag_id,
            schedule,
            croniter.is_valid(schedule) if schedule else None,
            dag.is_paused,
            dag.is_active,
            dag.has_import_errors,
            task_count,
            dag.next_dagrun_data_interval_end,
            snapshot_at,
        ))
    return rows


def _task_rows(session, snapshot_at):
    since = snapshot_at - timedelta(days=HISTORY_DAYS)
    query = (
        session.query(TaskInstance, DagRun.run_type)
        .join(DagRun, (DagRun.dag_id == TaskInstance.dag_id)
              & (DagRun.run_id == TaskInstance.run_id))
        .filter(DagRun.start_date >= since)
    )
    return [
        (ti.dag_id, ti.task_id, ti.run_id, run_type, ti.state, ti.try_number,
         ti.start_date, ti.end_date, ti.duration, snapshot_at)
        for ti, run_type in query
    ]


def stage_airflow_metadata(**context):
    snapshot_at = datetime.now(timezone.utc)
    with create_session() as session:
        dags = _dag_rows(session, snapshot_at)
        tasks = _task_rows(session, snapshot_at)

    def load(cur):
        cur.execute('DELETE FROM stg.airflow_dags')
        cur.executemany(
            'INSERT INTO stg.airflow_dags (dag_id, schedule, is_cron_valid, is_paused, '
            'is_active, has_import_errors, task_count, next_run_at, snapshot_at) '
            'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)',
            dags,
        )
        cur.execute('DELETE FROM stg.airflow_task_runs')
        if tasks:
            cur.executemany(
                'INSERT INTO stg.airflow_task_runs (dag_id, task_id, run_id, run_type, '
                'state, try_number, start_date, end_date, duration, snapshot_at) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',
                tasks,
            )
        return len(dags) + len(tasks), None

    run_audited(load, 'airflow metadata', 'stg.airflow_dags, stg.airflow_task_runs', **context)
