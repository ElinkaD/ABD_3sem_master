CREATE TABLE IF NOT EXISTS dds.s_person_info (
    hk_person_id INTEGER NOT NULL CONSTRAINT fk_s_person_info_person
        REFERENCES dds.h_people (hk_person_id),
    name VARCHAR(200),
    date_of_birthday DATE,
    country VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(200),
    hashdiff INTEGER NOT NULL,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY hk_person_id, load_date
SEGMENTED BY hash(hk_person_id) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.s_group_info (
    hk_group_id INTEGER NOT NULL CONSTRAINT fk_s_group_info_group
        REFERENCES dds.h_groups (hk_group_id),
    title VARCHAR(200),
    status VARCHAR(50),
    hashdiff INTEGER NOT NULL,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY hk_group_id, load_date
SEGMENTED BY hash(hk_group_id) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.s_chat_info (
    hk_msg_id INTEGER NOT NULL CONSTRAINT fk_s_chat_info_msg
        REFERENCES dds.h_chats (hk_msg_id),
    text_msg VARCHAR(1000),
    msg_from INTEGER,
    msg_to INTEGER,
    status VARCHAR(50),
    hashdiff INTEGER NOT NULL,
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY hk_msg_id, load_date
SEGMENTED BY hash(hk_msg_id) ALL NODES
PARTITION BY load_date::DATE;
