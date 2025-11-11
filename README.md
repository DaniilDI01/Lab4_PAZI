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
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Documentation: http://localhost:8000/docs
# Database: localhost:5432


## API Endpoints

- `POST /register` - Регистрация нового пользователя
- `GET /users` - Получение списка пользователей
- `GET /users/{id}` - Получение пользователя по ID