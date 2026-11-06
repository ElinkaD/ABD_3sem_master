CREATE SCHEMA IF NOT EXISTS dds;

CREATE TABLE IF NOT EXISTS dds.h_people (
    hk_person_id INTEGER PRIMARY KEY,
    person_id INTEGER NOT NULL,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_person_id) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.h_groups (
    hk_group_id INTEGER PRIMARY KEY,
    group_id INTEGER NOT NULL,
    created_date TIMESTAMP,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_group_id) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.h_chats (
    hk_msg_id INTEGER PRIMARY KEY,
    msg_id INTEGER NOT NULL,
    msg_time TIMESTAMP,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_msg_id) ALL NODES
PARTITION BY load_date::DATE;
