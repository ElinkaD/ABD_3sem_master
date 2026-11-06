INSERT INTO dds.s_person_info
    (hk_person_id, name, date_of_birthday, country, phone, email, hashdiff, source, load_date)
SELECT src.hk_person_id, src.name, src.date_of_birthday, src.country, src.phone, src.email,
       src.hashdiff, 'people.csv', now()
FROM (
    SELECT hash(p.id) AS hk_person_id, p.name, p.date_of_birthday, p.country, p.phone, p.email,
           hash(p.name, p.date_of_birthday, p.country, p.phone, p.email) AS hashdiff
    FROM stg.people p
) src
LEFT JOIN (
    SELECT hk_person_id, hashdiff,
           ROW_NUMBER() OVER (PARTITION BY hk_person_id ORDER BY load_date DESC) AS rn
    FROM dds.s_person_info
) cur ON cur.hk_person_id = src.hk_person_id AND cur.rn = 1
WHERE cur.hashdiff IS NULL OR cur.hashdiff <> src.hashdiff;
