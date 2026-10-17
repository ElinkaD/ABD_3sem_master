-- Задание 1, вариант 1. Таблицы модели данных магазина изделий ручной работы

DROP TABLE IF EXISTS craft_market_masters_products, craft_market_orders_customers,
                     craft_market_craftsmans, craft_market_customers, craft_market_orders;

CREATE TABLE craft_market_masters_products (
    craftsman_id        BIGINT NOT NULL,
    craftsman_name      VARCHAR NOT NULL,
    craftsman_address   VARCHAR NOT NULL,
    craftsman_birthday  DATE NOT NULL,
    craftsman_email     VARCHAR NOT NULL,
    product_id          BIGINT NOT NULL,
    product_name        VARCHAR NOT NULL,
    product_description VARCHAR NOT NULL,
    product_type        VARCHAR NOT NULL,
    product_price       BIGINT NOT NULL,
    PRIMARY KEY (craftsman_id, product_id)
);

CREATE TABLE craft_market_orders_customers (
    order_id              BIGINT PRIMARY KEY,
    craftsman_id          BIGINT NOT NULL,
    product_id            BIGINT NOT NULL,
    order_created_date    DATE NOT NULL,
    order_completion_date DATE,
    order_status          VARCHAR NOT NULL,
    customer_id           BIGINT NOT NULL,
    customer_name         VARCHAR NOT NULL,
    customer_address      VARCHAR NOT NULL,
    customer_birthday     DATE NOT NULL,
    customer_email        VARCHAR NOT NULL
);

CREATE TABLE craft_market_craftsmans (
    craftsman_id       BIGINT PRIMARY KEY,
    craftsman_name     VARCHAR NOT NULL,
    craftsman_address  VARCHAR NOT NULL,
    craftsman_birthday DATE NOT NULL,
    craftsman_email    VARCHAR NOT NULL
);

CREATE TABLE craft_market_customers (
    customer_id       BIGINT PRIMARY KEY,
    customer_name     VARCHAR NOT NULL,
    customer_address  VARCHAR NOT NULL,
    customer_birthday DATE NOT NULL,
    customer_email    VARCHAR NOT NULL
);

CREATE TABLE craft_market_orders (
    order_id              BIGINT PRIMARY KEY,
    product_id            BIGINT NOT NULL,
    craftsman_id          BIGINT NOT NULL REFERENCES craft_market_craftsmans (craftsman_id),
    customer_id           BIGINT NOT NULL REFERENCES craft_market_customers (customer_id),
    order_created_date    DATE NOT NULL,
    order_completion_date DATE,
    order_status          VARCHAR NOT NULL,
    product_name          VARCHAR NOT NULL,
    product_description   VARCHAR NOT NULL,
    product_type          VARCHAR NOT NULL,
    product_price         BIGINT NOT NULL
);
