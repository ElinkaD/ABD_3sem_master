CREATE SCHEMA IF NOT EXISTS etl;

CREATE TABLE IF NOT EXISTS etl.load_runs (
    id IDENTITY PRIMARY KEY,
    dag_id VARCHAR(250) NOT NULL,
    task_id VARCHAR(250) NOT NULL,
    attempt INTEGER NOT NULL,
    source VARCHAR(500) NOT NULL,
    target_table VARCHAR(250) NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    finished_at TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'running',
    row_count INTEGER,
    rejected_count INTEGER,
    error VARCHAR(4000),
    CONSTRAINT load_runs_status_chk
        CHECK (status IN ('running', 'success', 'failed'))
)
ORDER BY target_table, started_at
UNSEGMENTED ALL NODES;
