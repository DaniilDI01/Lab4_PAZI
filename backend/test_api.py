import requests

BASE_URL = "http://localhost:8000"

def run_tests():
    print("🧪 Testing Registration API\n")
    
    # Тест 1: Успешная регистрация
    print("1. Testing successful registration...")
    response = requests.post(f"{BASE_URL}/register", json={
        "login": "john_doe",
        "password": "SecurePass123!"
    })
    print(f"   Status: {response.status_code}, Response: {response.json()}")
    
    # Тест 2: Плохой пароль
    print("\n2. Testing bad password...")
    response = requests.post(f"{BASE_URL}/register", json={
        "login": "jane_doe", 
        "password": "weak"
    })
    print(f"   Status: {response.status_code}, Response: {response.json()}")
    
    # Тест 3: Плохой логин
    print("\n3. Testing bad login...")
    response = requests.post(f"{BASE_URL}/register", json={
        "login": "ab",
        "password": "GoodPass123!"
    })
    print(f"   Status: {response.status_code}, Response: {response.json()}")
    
    # Тест 4: Дубликат логина
    print("\n4. Testing duplicate login...")
    response = requests.post(f"{BASE_URL}/register", json={
        "login": "john_doe",  # Уже существует
        "password": "AnotherPass123!"
    })
    print(f"   Status: {response.status_code}, Response: {response.json()}")

if __name__ == "__main__":
    run_tests()