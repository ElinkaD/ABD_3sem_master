CREATE SCHEMA IF NOT EXISTS monitoring;

CREATE TABLE IF NOT EXISTS monitoring.expected_schedules (
    dag_id VARCHAR(250) PRIMARY KEY,
    expected_schedule VARCHAR(100) NOT NULL,
    description VARCHAR(500)
)
UNSEGMENTED ALL NODES;

CREATE TABLE IF NOT EXISTS monitoring.dag_schedule_check (
    dag_id VARCHAR(250) NOT NULL,
    expected_schedule VARCHAR(100),
    actual_schedule VARCHAR(100),
    is_registered BOOLEAN NOT NULL,
    is_present BOOLEAN NOT NULL,
    is_cron_valid BOOLEAN,
    is_schedule_match BOOLEAN,
    is_paused BOOLEAN,
    has_import_errors BOOLEAN,
    task_count INTEGER,
    next_run_at TIMESTAMPTZ,
    last_run_start TIMESTAMPTZ,
    last_run_state VARCHAR(50),
    is_overdue BOOLEAN,
    check_status VARCHAR(50) NOT NULL,
    checked_at TIMESTAMPTZ NOT NULL
)
ORDER BY dag_id
UNSEGMENTED ALL NODES;

CREATE TABLE IF NOT EXISTS monitoring.task_status (
    dag_id VARCHAR(250) NOT NULL,
    task_id VARCHAR(250) NOT NULL,
    last_run_id VARCHAR(250),
    last_state VARCHAR(50),
    last_try_number INTEGER,
    last_start TIMESTAMPTZ,
    last_end TIMESTAMPTZ,
    last_duration_sec FLOAT,
    runs_30d INTEGER NOT NULL,
    success_30d INTEGER NOT NULL,
    failed_30d INTEGER NOT NULL,
    success_rate_30d NUMERIC(5, 2),
    avg_duration_sec FLOAT,
    last_failure_at TIMESTAMPTZ,
    checked_at TIMESTAMPTZ NOT NULL
)
ORDER BY dag_id, task_id
UNSEGMENTED ALL NODES;
