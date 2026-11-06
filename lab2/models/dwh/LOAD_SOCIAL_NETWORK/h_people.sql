INSERT INTO dds.h_people (hk_person_id, person_id, source, load_date)
SELECT DISTINCT hash(p.id), p.id, 'people.csv', now()
FROM stg.people p
WHERE hash(p.id) NOT IN (SELECT hk_person_id FROM dds.h_people);

INSERT INTO dds.h_people (hk_person_id, person_id, source, load_date)
SELECT DISTINCT hash(g.owner_id), g.owner_id, 'groups.csv', now()
FROM stg.groups g
WHERE hash(g.owner_id) NOT IN (SELECT hk_person_id FROM dds.h_people);

INSERT INTO dds.h_people (hk_person_id, person_id, source, load_date)
SELECT DISTINCT hash(c.msg_from), c.msg_from, 'chats.csv', now()
FROM stg.chats c
WHERE c.msg_from IS NOT NULL
  AND hash(c.msg_from) NOT IN (SELECT hk_person_id FROM dds.h_people);
