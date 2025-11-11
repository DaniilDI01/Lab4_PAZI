# Система регистрации пользователей

Микросервисная система регистрации пользователей с React фронтендом, FastAPI бэкендом и PostgreSQL базой данных.

## Архитектура


┌─────────────┐    HTTP     ┌─────────────┐    SQL     ┌─────────────┐
│  Frontend   │ ──────────→ │   Backend   │ ─────────→ │  Database   │
│  (React)    │ ←────────── │  (FastAPI)  │ ←───────── │ (PostgreSQL)│
│ localhost:3000 │          │ localhost:8000 │         │ localhost:5432 │
└─────────────┘             └─────────────┘         └─────────────┘


- **Frontend**: React + TypeScript + Vite
- **Backend**: FastAPI с хэшированием паролей Argon2  
- **Database**: PostgreSQL с уникальными ограничениями


# Запустить все сервисы
docker compose up --build

# Доступ к приложению:
## Frontend: http://localhost:3000
## Backend API: http://localhost:8000
## API Documentation: http://localhost:8000/docs
## Database: localhost:5432


## API Endpoints

- `POST /register` - Регистрация нового пользователя
- `GET /users` - Получение списка пользователей
- `GET /users/{id}` - Получение пользователя по ID


# Примеры использования через curl

### Успешная регистрация
```bash
curl -X POST "http://localhost:8000/register" \
  -H "Content-Type: application/json" \
  -d '{"login": "john_doe", "password": "SecurePass123!"}'
```
**Ответ:** `{"message":"user created successfully"}`

### Ошибка валидации логина
```bash
curl -X POST "http://localhost:8000/register" \
  -H "Content-Type: application/json" \
  -d '{"login": "ab", "password": "GoodPass123!"}'
```
**Ответ:** `422 - Login must be 3-32 characters`

### Ошибка валидации пароля
```bash
curl -X POST "http://localhost:8000/register" \
  -H "Content-Type: application/json" \
  -d '{"login": "testuser", "password": "weak"}'
```
**Ответ:** `422 - Password must be at least 8 characters`

### Конфликт логина
```bash
curl -X POST "http://localhost:8000/register" \
  -H "Content-Type: application/json" \
  -d '{"login": "john_doe", "password": "AnotherPass123!"}'
```
**Ответ:** `409 - Login already exists`

### Проверка здоровья сервиса
```bash
curl http://localhost:8000/health
```
**Ответ:** `{"status":"healthy","database":"connected"}`
```


# Безопасность: что сделано

### 🔐 Хранение паролей
- **Argon2id** - современный алгоритм хэширования
- Автоматическая соль для каждого пароля
- Никогда не храним пароли в открытом виде - только хэши
- Оптимизированные параметры для Docker-среды:
  - `ARGON2_TIME_COST=3` - баланс безопасности и производительности
  - `ARGON2_MEMORY_COST=65536` (64MB) - защита от GPU-атак
  - `ARGON2_PARALLELISM=1` - стабильная работа в контейнерах

### 🛡️ Защита данных
- Уникальный индекс на поле login - защита от дублирования
- Параметризованные запросы - защита от SQL-инъекций
- Валидация входных данных на стороне сервера
- CORS политики для безопасного взаимодействия frontend-backend

### 📝 Логирование и мониторинг
- Структурированное логирование с уровнями INFO/ERROR
- Никогда не логируем пароли в открытом виде
- Логируем события регистрации и ошибки валидации
- Отдельные логи для security events

### 🔒 Конфигурация безопасности
- Переменные окружения для всех чувствительных параметров
- SECRET_KEY для подписей (готовность к JWT)
- Разделение конфигов development/production через APP_ENV
