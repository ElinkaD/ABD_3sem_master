# ABD_3sem_master
ИТМО Мага Аналитика больших данных 3 сем

## Запуск

```bash
docker compose up -d --wait
docker compose ps
```

## Подключение к БД

```text
host: localhost
port: 5433
database: craft_market
user: user
password: 12345
```

Настройки локальной базы можно изменить через `.env` по примеру `.env.example`.

Через терминал:

```bash
docker compose exec postgres psql -U user -d craft_market
```

