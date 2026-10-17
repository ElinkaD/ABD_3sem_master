# ABD_3sem_master

Лабораторная работа 1, вариант 1 заданий 1 и 2; задание 3 — общее.

## Запуск

Из корня репозитория:

```powershell
docker compose -f lab1/docker-compose.yml up -d --build --wait
docker compose -f lab1/docker-compose.yml exec airflow cat /opt/airflow/standalone_admin_password.txt
```

Airflow: http://localhost:8081, логин `admin`, пароль — из второй команды.
PostgreSQL: `localhost:5434`, база хранилища `craft_market`, по умолчанию
пользователь `user`, пароль `12345`. Источник задания 3 — отдельная база `source`.

## Что реализовано

| Задание | Результат | Запуск |
| --- | --- | --- |
| 1 | Месячная витрина по заказчикам `public.customer_report`: суммы, комиссия 10%, количество и статусы заказов, средняя стоимость, медиана, популярные категория и мастер | `public.LOAD_CUSTOMER_REPORT`, вручную через Trigger DAG |
| 2 | Три CSV в отдельных таблицах схемы `external_source`; необходимые поля, техническое время загрузки и проверки | Три DAG-а `external_source.LOAD_*`, вручную через Trigger DAG |
| 3 | Триггеры записывают изменения в `source.logs`; Airflow переносит журнал и MongoDB в STG, сохраняя позицию загрузки | `stg.LOAD_SOURCE_LOGS` и `stg.LOAD_MONGO`, каждые 15 минут; доступен и ручной запуск |

Загрузки заданий 1 и 2 состоят из двух задач. Первая пересоздаёт таблицу
в постоянной рабочей схеме `wrk`: SQL-модель рассчитывает витрину, а CSV-загрузчик
копирует файл. Вторая общая задача `load_task` атомарно заменяет данные целевой
таблицы, добавляет `loaded_at`, сверяет количество строк и записывает результат
в `etl.load_runs`. Такое разделение позволяет позже подключить другой тип
источника, сохранив общий перенос `wrk → target`.

CSV размещаются в `lab1/data/external_source/`; DDL и начальные данные —
в `lab1/data/schemas/` и `lab1/data/seeds/`. Таблицы и начальные данные готовятся
автоматически. После изменения DDL стенд пересоздаётся с чистыми томами:

```powershell
docker compose -f lab1/docker-compose.yml down -v
docker compose -f lab1/docker-compose.yml up -d --build --wait
```
