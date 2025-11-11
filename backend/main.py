from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.context import CryptContext
import psycopg2
import time
import re
import logging
import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Конфигурация из .env
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://user:password@db:5432/registration_db')
SECRET_KEY = os.getenv('SECRET_KEY', 'fallback-secret-key')
APP_ENV = os.getenv('APP_ENV', 'development')
PORT = int(os.getenv('PORT', 8000))

# Используем Argon2 с параметрами из .env
pwd_context = CryptContext(
    schemes=[os.getenv('HASH_SCHEME', 'argon2')],
    argon2__time_cost=int(os.getenv('ARGON2_TIME_COST', 3)),
    argon2__memory_cost=int(os.getenv('ARGON2_MEMORY_COST', 65536)),
    argon2__parallelism=int(os.getenv('ARGON2_PARALLELISM', 1)),
    deprecated="auto"
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class UserRegister(BaseModel):
    login: str
    password: str

def get_db_connection():
    """Подключение к БД с повторными попытками"""
    max_retries = 5
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(
                host="db",
                database="registration_db",
                user="user",
                password="password",
                connect_timeout=5
            )
            logger.info("✅ Database connection successful")
            return conn
        except Exception as e:
            logger.warning(f"❌ Database connection attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(2)
            else:
                logger.error("💥 All database connection attempts failed")
                raise

def create_table():
    """Создание таблицы"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                login VARCHAR(32) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        cur.close()
        conn.close()
        logger.info("✅ Table 'users' created successfully")
    except Exception as e:
        logger.error(f"💥 Failed to create table: {e}")
        raise

@app.on_event("startup")
def startup():
    logger.info("🚀 Starting backend application...")
    try:
        create_table()
        logger.info("✅ Startup completed successfully")
    except Exception as e:
        logger.error(f"💥 Startup failed: {e}")

@app.post("/register")
async def register(user: UserRegister):
    logger.info(f"📝 Registration attempt for user: {user.login}")
    
    try:
        # Валидация логина
        if len(user.login) < 3 or len(user.login) > 32:
            logger.warning(f"❌ Login validation failed: length {len(user.login)}")
            raise HTTPException(status_code=422, detail="Login must be 3-32 characters")
        
        if not re.match(r'^[a-zA-Z0-9._-]+$', user.login):
            logger.warning(f"❌ Login validation failed: invalid characters")
            raise HTTPException(status_code=422, detail="Login can only contain letters, numbers, . _ -")
        
        # Валидация пароля
        if len(user.password) < 8:
            logger.warning("❌ Password validation failed: too short")
            raise HTTPException(status_code=422, detail="Password must be at least 8 characters")
        
        if not re.search(r'[A-Z]', user.password):
            logger.warning("❌ Password validation failed: no uppercase")
            raise HTTPException(status_code=422, detail="Password must contain at least one uppercase letter")
        
        if not re.search(r'[a-z]', user.password):
            logger.warning("❌ Password validation failed: no lowercase")
            raise HTTPException(status_code=422, detail="Password must contain at least one lowercase letter")
        
        if not re.search(r'\d', user.password):
            logger.warning("❌ Password validation failed: no digit")
            raise HTTPException(status_code=422, detail="Password must contain at least one digit")
        
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', user.password):
            logger.warning("❌ Password validation failed: no special character")
            raise HTTPException(status_code=422, detail="Password must contain at least one special character")
        
        # Подключение к БД и сохранение
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Проверяем существующий логин
        cur.execute("SELECT id FROM users WHERE login = %s", (user.login,))
        if cur.fetchone():
            logger.warning(f"❌ User already exists: {user.login}")
            raise HTTPException(status_code=409, detail="Login already exists")
        
        # Хэшируем пароль с Argon2
        hashed_password = pwd_context.hash(user.password)
        logger.info(f"🔐 Password hashed successfully for user: {user.login}")
        
        cur.execute(
            "INSERT INTO users (login, password_hash) VALUES (%s, %s)",
            (user.login, hashed_password)
        )
        
        conn.commit()
        cur.close()
        conn.close()
        
        logger.info(f"✅ User registered successfully: {user.login}")
        return {"message": "user created successfully"}
        
    except HTTPException:
        # Перебрасываем известные HTTP исключения
        raise
    except Exception as e:
        logger.error(f"💥 Unexpected error during registration: {e}")
        raise HTTPException(status_code=500, detail="Internal server error - check logs")

@app.get("/")
async def root():
    return {"message": "Registration API"}

@app.get("/health")
async def health():
    try:
        conn = get_db_connection()
        conn.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=PORT,
        reload=APP_ENV == "development"
    )