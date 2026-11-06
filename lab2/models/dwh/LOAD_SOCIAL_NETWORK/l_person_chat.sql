INSERT INTO dds.l_person_chat (hk_l_person_chat, hk_person_id, hk_msg_id, source, load_date)
SELECT DISTINCT hash(c.msg_from, c.msg_id), hash(c.msg_from), hash(c.msg_id), 'chats.csv', now()
FROM stg.chats c
WHERE c.msg_from IS NOT NULL
  AND hash(c.msg_from, c.msg_id) NOT IN (SELECT hk_l_person_chat FROM dds.l_person_chat);
