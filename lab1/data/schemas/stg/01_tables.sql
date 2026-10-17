CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dds;
CREATE SCHEMA IF NOT EXISTS cdm;

-- служебная таблица: место, до которого уже загружены данные из каждого источника
CREATE TABLE stg.settings (
    id           SERIAL PRIMARY KEY,
    settings_key VARCHAR NOT NULL UNIQUE,
    settings     JSONB NOT NULL
);

CREATE TABLE stg.pg_category (
    id            SERIAL PRIMARY KEY,
    category_id   INT NOT NULL UNIQUE,
    category_name VARCHAR NOT NULL,
    percent       NUMERIC(4, 2) NOT NULL,
    min_payment   NUMERIC(14, 2) NOT NULL
);

CREATE TABLE stg.pg_dish (
    id            SERIAL PRIMARY KEY,
    dish_id       INT NOT NULL UNIQUE,
    dish_name     VARCHAR NOT NULL,
    dish_category VARCHAR NOT NULL,
    price         NUMERIC(14, 2) NOT NULL
);

CREATE TABLE stg.pg_client (
    id            SERIAL PRIMARY KEY,
    client_id     INT NOT NULL UNIQUE,
    name          VARCHAR NOT NULL,
    phone         VARCHAR,
    email         VARCHAR,
    birthday      DATE,
    login         VARCHAR,
    category_id   INT,
    bonus_balance NUMERIC(14, 2) NOT NULL
);

-- копия журнала изменений источника
CREATE TABLE stg.pg_logs (
    id          INT PRIMARY KEY, -- id записи в source.logs
    update_ts   TIMESTAMP NOT NULL,
    object_type VARCHAR NOT NULL,
    object_id   VARCHAR NOT NULL,
    operation   VARCHAR NOT NULL,
    payload     JSONB NOT NULL
);

CREATE TABLE stg.mongo_clients (
    id           SERIAL PRIMARY KEY,
    object_id    VARCHAR NOT NULL UNIQUE,
    object_value TEXT NOT NULL,
    update_ts    TIMESTAMP NOT NULL
);

CREATE TABLE stg.mongo_restaurants (
    id           SERIAL PRIMARY KEY,
    object_id    VARCHAR NOT NULL UNIQUE,
    object_value TEXT NOT NULL,
    update_ts    TIMESTAMP NOT NULL
);

CREATE TABLE stg.mongo_orders (
    id           SERIAL PRIMARY KEY,
    object_id    VARCHAR NOT NULL UNIQUE,
    object_value TEXT NOT NULL,
    update_ts    TIMESTAMP NOT NULL
);