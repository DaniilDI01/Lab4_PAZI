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
