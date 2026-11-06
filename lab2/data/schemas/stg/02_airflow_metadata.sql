CREATE TABLE IF NOT EXISTS stg.airflow_dags (
    dag_id VARCHAR(250) NOT NULL,
    schedule VARCHAR(100),
    is_cron_valid BOOLEAN,
    is_paused BOOLEAN,
    is_active BOOLEAN,
    has_import_errors BOOLEAN,
    task_count INTEGER,
    next_run_at TIMESTAMPTZ,
    snapshot_at TIMESTAMPTZ NOT NULL
)
UNSEGMENTED ALL NODES;

CREATE TABLE IF NOT EXISTS stg.airflow_task_runs (
    dag_id VARCHAR(250) NOT NULL,
    task_id VARCHAR(250) NOT NULL,
    run_id VARCHAR(250) NOT NULL,
    run_type VARCHAR(50),
    state VARCHAR(50),
    try_number INTEGER,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    duration FLOAT,
    snapshot_at TIMESTAMPTZ NOT NULL
)
ORDER BY dag_id, task_id, start_date
UNSEGMENTED ALL NODES;
