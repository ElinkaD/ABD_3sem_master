INSERT INTO dds.h_chats (hk_msg_id, msg_id, msg_time, source, load_date)
SELECT DISTINCT hash(c.msg_id), c.msg_id, c.msg_time, 'chats.csv', now()
FROM stg.chats c
WHERE hash(c.msg_id) NOT IN (SELECT hk_msg_id FROM dds.h_chats);
