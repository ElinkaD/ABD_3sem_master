DELETE FROM cdm.person_activity;

INSERT INTO cdm.person_activity
    (person_id, name, country, messages_sent, groups_owned, groups_written, last_msg_time, loaded_at)
WITH person_info AS (
    SELECT hk_person_id, name, country
    FROM dds.s_person_info
    LIMIT 1 OVER (PARTITION BY hk_person_id ORDER BY load_date DESC)
),
owners AS (
    SELECT hk_group_id, hk_person_id
    FROM dds.l_chat_owners
    LIMIT 1 OVER (PARTITION BY hk_group_id ORDER BY load_date DESC)
),
msg_groups AS (
    SELECT hk_msg_id, hk_group_id
    FROM dds.l_groups
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
),
msg_authors AS (
    SELECT hk_msg_id, hk_person_id
    FROM dds.l_person_chat
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
),
sent AS (
    SELECT ma.hk_person_id,
           COUNT(*) AS messages_sent,
           COUNT(DISTINCT mg.hk_group_id) AS groups_written,
           MAX(hc.msg_time) AS last_msg_time
    FROM msg_authors ma
    JOIN dds.h_chats hc ON hc.hk_msg_id = ma.hk_msg_id
    LEFT JOIN msg_groups mg ON mg.hk_msg_id = ma.hk_msg_id
    GROUP BY ma.hk_person_id
),
owned AS (
    SELECT hk_person_id, COUNT(*) AS groups_owned
    FROM owners
    GROUP BY hk_person_id
)
SELECT hp.person_id,
       pi.name,
       pi.country,
       COALESCE(s.messages_sent, 0),
       COALESCE(o.groups_owned, 0),
       COALESCE(s.groups_written, 0),
       s.last_msg_time,
       now()
FROM dds.h_people hp
LEFT JOIN person_info pi ON pi.hk_person_id = hp.hk_person_id
LEFT JOIN sent s ON s.hk_person_id = hp.hk_person_id
LEFT JOIN owned o ON o.hk_person_id = hp.hk_person_id;
