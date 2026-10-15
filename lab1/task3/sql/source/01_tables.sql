CREATE TABLE category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR NOT NULL,
    percent       NUMERIC(4, 2) NOT NULL, -- доля бонусов, например 0.3
    min_payment   NUMERIC(14, 2) NOT NULL -- минимальная сумма покупок для категории
);

-- блюда
CREATE TABLE dish (
    dish_id       SERIAL PRIMARY KEY,
    dish_name     VARCHAR NOT NULL,
    dish_category VARCHAR NOT NULL,
    price         NUMERIC(14, 2) NOT NULL
);

-- клиенты программы лояльности
CREATE TABLE client (
    client_id     SERIAL PRIMARY KEY,
    name          VARCHAR NOT NULL,
    phone         VARCHAR,
    email         VARCHAR,
    birthday      DATE,
    login         VARCHAR,
    category_id   INT REFERENCES category (category_id),
    bonus_balance NUMERIC(14, 2) NOT NULL DEFAULT 0
);

-- журнал всех изменений в таблицах БД
CREATE TABLE logs (
    id          SERIAL PRIMARY KEY,
    update_ts   TIMESTAMP NOT NULL DEFAULT now(),
    object_type VARCHAR NOT NULL,
    object_id   VARCHAR NOT NULL,
    operation   VARCHAR NOT NULL,
    payload     JSONB NOT NULL
);
