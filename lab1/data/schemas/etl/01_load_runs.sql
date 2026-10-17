-- Общий технический журнал, отдельно от оболочек таблиц источников.
CREATE SCHEMA IF NOT EXISTS etl;
CREATE TABLE IF NOT EXISTS etl.load_runs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dag_id TEXT NOT NULL,
    attempt INTEGER NOT NULL,
    source_file TEXT NOT NULL,
    target_table TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    loaded_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'running'
        CHECK (status IN ('running', 'success', 'failed')),
    row_count BIGINT,
    error TEXT
);
CREATE INDEX IF NOT EXISTS load_runs_target_started_idx
    ON etl.load_runs (target_table, started_at DESC, id DESC);
