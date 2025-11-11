-- Таблица создается автоматически в backend, но можно добавить индексы
CREATE INDEX IF NOT EXISTS idx_users_login ON users(login);