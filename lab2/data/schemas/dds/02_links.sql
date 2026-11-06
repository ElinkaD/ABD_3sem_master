CREATE TABLE IF NOT EXISTS dds.l_chat_owners (
    hk_l_owner_id INTEGER PRIMARY KEY,
    hk_person_id INTEGER NOT NULL CONSTRAINT fk_l_chat_owners_person
        REFERENCES dds.h_people (hk_person_id),
    hk_group_id INTEGER NOT NULL CONSTRAINT fk_l_chat_owners_group
        REFERENCES dds.h_groups (hk_group_id),
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_l_owner_id) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.l_person_chat (
    hk_l_person_chat INTEGER PRIMARY KEY,
    hk_person_id INTEGER NOT NULL CONSTRAINT fk_l_person_chat_person
        REFERENCES dds.h_people (hk_person_id),
    hk_msg_id INTEGER NOT NULL CONSTRAINT fk_l_person_chat_msg
        REFERENCES dds.h_chats (hk_msg_id),
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_l_person_chat) ALL NODES
PARTITION BY load_date::DATE;

CREATE TABLE IF NOT EXISTS dds.l_groups (
    hk_l_group_id INTEGER PRIMARY KEY,
    hk_msg_id INTEGER NOT NULL CONSTRAINT fk_l_groups_msg
        REFERENCES dds.h_chats (hk_msg_id),
    hk_group_id INTEGER NOT NULL CONSTRAINT fk_l_groups_group
        REFERENCES dds.h_groups (hk_group_id),
    source VARCHAR(100) NOT NULL,
    load_date TIMESTAMP NOT NULL
)
ORDER BY load_date
SEGMENTED BY hash(hk_l_group_id) ALL NODES
PARTITION BY load_date::DATE;
