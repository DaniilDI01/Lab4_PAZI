#!/bin/bash

echo "🚀 Creating React + TypeScript frontend with dark theme..."

# Создаём структуру папок
mkdir -p src

# package.json
cat > package.json << 'EOF'
{
  "name": "frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.0",
    "vite": "^4.4.0"
  }
}
EOF

# vite.config.ts
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 3000
  }
})
EOF

# tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# tsconfig.node.json
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

# index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>User Registration</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# src/main.tsx
cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# src/index.css (тёмная тема)
cat > src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background: #0f0f0f;
  color: #ffffff;
  min-height: 100vh;
}

#root {
  min-height: 100vh;
}
EOF

# src/App.tsx (минималистичный с тёмной темой)
cat > src/App.tsx << 'EOF'
import React, { useState } from 'react'
import './App.css'

interface RegistrationResponse {
  message: string
}

interface ErrorResponse {
  detail: string
}

function App() {
  const [login, setLogin] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState('')
  const [isError, setIsError] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setMessage('')

    try {
      const response = await fetch('http://localhost:8000/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ login, password }),
      })

      const data: RegistrationResponse | ErrorResponse = await response.json()

      if (response.ok) {
        setMessage('✅ ' + (data as RegistrationResponse).message)
        setIsError(false)
        setLogin('')
        setPassword('')
      } else {
        setMessage('❌ ' + (data as ErrorResponse).detail)
        setIsError(true)
      }
    } catch (error) {
      setMessage('❌ Connection error')
      setIsError(true)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="app">
      <div className="container">
        <h1>Register</h1>
        
        <form onSubmit={handleSubmit} className="form">
          <div className="input-group">
            <input
              type="text"
              value={login}
              onChange={(e) => setLogin(e.target.value)}
              placeholder="Username"
              required
              disabled={isLoading}
            />
          </div>

          <div className="input-group">
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Password"
              required
              disabled={isLoading}
            />
          </div>

          <button type="submit" disabled={isLoading} className="submit-btn">
            {isLoading ? '...' : 'Register'}
          </button>
        </form>

        {message && (
          <div className={`message ${isError ? 'error' : 'success'}`}>
            {message}
          </div>
        )}

        <div className="requirements">
          <div>Username: 3-32 chars, a-z 0-9 ._-</div>
          <div>Password: 8+ chars, A-Z a-z 0-9 special</div>
        </div>
      </div>
    </div>
  )
}

export default App
EOF

# src/App.css (минималистичный тёмный стиль)
cat > src/App.css << 'EOF'
.app {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: #0f0f0f;
}

.container {
  background: #1a1a1a;
  padding: 40px 30px;
  border-radius: 12px;
  border: 1px solid #333;
  width: 100%;
  max-width: 400px;
}

h1 {
  text-align: center;
  color: #fff;
  margin-bottom: 30px;
  font-size: 24px;
  font-weight: 300;
  letter-spacing: 1px;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.input-group {
  display: flex;
  flex-direction: column;
}

input {
  padding: 14px 16px;
  background: #2a2a2a;
  border: 1px solid #444;
  border-radius: 8px;
  color: #fff;
  font-size: 14px;
  transition: all 0.2s;
}

input::placeholder {
  color: #888;
}

input:focus {
  outline: none;
  border-color: #666;
  background: #333;
}

input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.submit-btn {
  padding: 14px;
  background: #fff;
  color: #000;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 10px;
}

.submit-btn:hover:not(:disabled) {
  background: #e0e0e0;
}

.submit-btn:disabled {
  background: #666;
  cursor: not-allowed;
}

.message {
  padding: 12px 16px;
  border-radius: 8px;
  text-align: center;
  font-size: 14px;
  margin-top: 20px;
  border: 1px solid;
}

.success {
  background: #1a2a1a;
  color: #4ade80;
  border-color: #2d5a2d;
}

.error {
  background: #2a1a1a;
  color: #f87171;
  border-color: #5a2d2d;
}

.requirements {
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #333;
  font-size: 12px;
  color: #888;
  line-height: 1.5;
}

.requirements div {
  margin-bottom: 5px;
}
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

echo "✅ Frontend created successfully!"
echo "📦 Install dependencies: npm install"
echo "🚀 Start dev server: npm run dev"
echo "🐳 Build for production: npm run build"