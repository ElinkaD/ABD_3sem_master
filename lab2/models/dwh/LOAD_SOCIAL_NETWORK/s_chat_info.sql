INSERT INTO dds.s_chat_info
    (hk_msg_id, text_msg, msg_from, msg_to, status, hashdiff, source, load_date)
SELECT src.hk_msg_id, src.text_msg, src.msg_from, src.msg_to, NULL, src.hashdiff,
       'chats.csv', now()
FROM (
    SELECT hash(c.msg_id) AS hk_msg_id, c.text_message AS text_msg, c.msg_from, c.msg_to,
           hash(c.text_message, c.msg_from, c.msg_to) AS hashdiff
    FROM stg.chats c
) src
LEFT JOIN (
    SELECT hk_msg_id, hashdiff,
           ROW_NUMBER() OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC) AS rn
    FROM dds.s_chat_info
) cur ON cur.hk_msg_id = src.hk_msg_id AND cur.rn = 1
WHERE cur.hashdiff IS NULL OR cur.hashdiff <> src.hashdiff;
