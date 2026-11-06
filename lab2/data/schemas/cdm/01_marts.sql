CREATE SCHEMA IF NOT EXISTS cdm;

CREATE TABLE IF NOT EXISTS cdm.group_activity (
    group_id INTEGER NOT NULL,
    title VARCHAR(200),
    created_date TIMESTAMP,
    owner_id INTEGER,
    owner_name VARCHAR(200),
    messages_cnt INTEGER NOT NULL,
    senders_cnt INTEGER NOT NULL,
    first_msg_time TIMESTAMP,
    last_msg_time TIMESTAMP,
    loaded_at TIMESTAMP NOT NULL
)
ORDER BY group_id
UNSEGMENTED ALL NODES;

CREATE TABLE IF NOT EXISTS cdm.person_activity (
    person_id INTEGER NOT NULL,
    name VARCHAR(200),
    country VARCHAR(200),
    messages_sent INTEGER NOT NULL,
    groups_owned INTEGER NOT NULL,
    groups_written INTEGER NOT NULL,
    last_msg_time TIMESTAMP,
    loaded_at TIMESTAMP NOT NULL
)
ORDER BY person_id
UNSEGMENTED ALL NODES;

CREATE TABLE IF NOT EXISTS cdm.messages_monthly (
    report_month DATE NOT NULL,
    messages_cnt INTEGER NOT NULL,
    senders_cnt INTEGER NOT NULL,
    groups_cnt INTEGER NOT NULL,
    loaded_at TIMESTAMP NOT NULL
)
ORDER BY report_month
UNSEGMENTED ALL NODES;
