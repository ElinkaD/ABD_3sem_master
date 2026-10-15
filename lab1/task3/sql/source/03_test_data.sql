INSERT INTO category (category_name, percent, min_payment) VALUES
    ('bronze', 0.05, 0),
    ('silver', 0.10, 10000),
    ('gold',   0.30, 100000);

INSERT INTO dish (dish_name, dish_category, price) VALUES
    ('ОВОЩИ ПО-МЕКСИКАНСКИ', 'Закуски', 60),
    ('КУРИЦА',               'Закуски', 60),
    ('РОЛЛ',                 'Закуски', 120),
    ('БОРЩ',                 'Супы',    250);

INSERT INTO client (name, phone, email, birthday, login, category_id, bonus_balance) VALUES
    ('Иванова Инна Ивановна',      '5824585', 'iii@mail.ru', '2014-04-30', 'iii',    1, 0),
    ('Екатерина Романовна Дашкова', '5824587', 'erd@mail.ru', '1991-01-01', 'kati17', 2, 150);

-- изменения, чтобы в журнале были не только вставки
UPDATE client SET category_id = 3, bonus_balance = 400 WHERE login = 'kati17';
UPDATE dish SET price = 130 WHERE dish_name = 'РОЛЛ';
