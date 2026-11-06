CREATE SCHEMA IF NOT EXISTS stg;

CREATE TABLE IF NOT EXISTS stg.people (
    id INTEGER NOT NULL,
    name VARCHAR(200),
    registration_date TIMESTAMP,
    country VARCHAR(200),
    date_of_birthday DATE,
    phone VARCHAR(20),
    email VARCHAR(200),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
)
ORDER BY id
SEGMENTED BY hash(id) ALL NODES;

CREATE TABLE IF NOT EXISTS stg.groups (
    id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    group_name VARCHAR(200),
    created_date TIMESTAMP,
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
)
ORDER BY id
SEGMENTED BY hash(id) ALL NODES;

CREATE TABLE IF NOT EXISTS stg.chats (
    msg_id INTEGER NOT NULL,
    msg_time TIMESTAMP,
    msg_from INTEGER,
    msg_to INTEGER,
    text_message VARCHAR(1000),
    msg_group_id INTEGER,
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
)
ORDER BY msg_id
SEGMENTED BY hash(msg_id) ALL NODES;
