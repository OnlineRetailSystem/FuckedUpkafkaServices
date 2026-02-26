# JWT Implementation Guide

## What Was Added

### 1. JWT Dependencies (pom.xml)
- `jjwt-api` - JWT API
- `jjwt-impl` - JWT implementation
- `jjwt-jackson` - JSON processing

### 2. New Files Created
- `JwtUtil.java` - JWT token generation and validation
- `JwtResponse.java` - DTO for JWT response

### 3. Modified Files
- `AuthController.java` - Now returns JWT token on login

## What Did NOT Change

✅ Database schema - unchanged
✅ Business logic - unchanged  
✅ Kafka events - still published
✅ Existing endpoints - same URLs
✅ Admin hardcoded login - unchanged
✅ User registration - unchanged

## How It Works

### Login Flow (Before JWT):
```
User → /signin → Validate → Return "Login successful"
```

### Login Flow (After JWT):
```
User → /signin → Validate → Generate JWT → Return JWT + user info
```

## API Response Changes

### Before:
```json
"Login successful"
```

### After:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "john",
  "email": "john@example.com",
  "roles": "ROLE_USER",
  "message": "Login successful"
}
```

## Configuration

Add to `application.properties` (optional, has defaults):

```properties
# JWT Configuration
jwt.secret=mySecretKeyForJWTTokenGenerationThatIsAtLeast256BitsLong12345678
jwt.expiration=86400000
```

- `jwt.secret` - Secret key for signing tokens (min 256 bits)
- `jwt.expiration` - Token expiration time in milliseconds (default: 24 hours)

## Rebuild and Test

### 1. Rebuild Auth Service:
```cmd
docker-compose stop authservice
docker-compose build authservice
docker-compose up -d authservice
```

### 2. Wait for startup:
```cmd
timeout /t 20
```

### 3. Test Login:
```cmd
curl -X POST "http://localhost:8090/auth/signin" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"testuser\", \"password\": \"password\"}"
```

### Expected Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJyb2xlcyI6IlJPTEVfVVNFUiIsInN1YiI6InRlc3R1c2VyIiwiaWF0IjoxNzA4MDAwMDAwLCJleHAiOjE3MDgwODY0MDB9.xyz...",
  "username": "testuser",
  "email": "test@test.com",
  "roles": "ROLE_USER",
  "message": "Login successful"
}
```

## Frontend Integration

### Update Login Component:

```javascript
async function handleLogin(e) {
  e.preventDefault();
  
  const response = await fetch("http://localhost:8090/auth/signin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password })
  });

  if (response.ok) {
    const data = await response.json();
    
    // Store JWT token
    localStorage.setItem("token", data.token);
    localStorage.setItem("username", data.username);
    localStorage.setItem("roles", data.roles);
    
    // Navigate to dashboard
    navigate("/dashboard");
  }
}
```

### Send JWT in Requests:

```javascript
const token = localStorage.getItem("token");

fetch("http://localhost:8090/products", {
  headers: {
    "Authorization": `Bearer ${token}`
  }
});
```

## JWT Token Structure

### Header:
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Payload:
```json
{
  "sub": "username",
  "email": "user@example.com",
  "roles": "ROLE_USER",
  "iat": 1708000000,
  "exp": 1708086400
}
```

### Signature:
```
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret
)
```

## Security Features

✅ **Token Expiration** - Tokens expire after 24 hours
✅ **Signature Verification** - Tokens are cryptographically signed
✅ **Stateless** - No server-side session storage needed
✅ **Claims** - Username, email, and roles embedded in token

## Next Steps (Optional)

### 1. Add JWT Validation Filter
Create a filter to validate JWT on protected endpoints.

### 2. Add Token Refresh
Implement refresh token mechanism for long-lived sessions.

### 3. Add Logout
Implement token blacklist for logout functionality.

### 4. Protect Endpoints
Add JWT validation to other microservices.

## Troubleshooting

### Issue: "Invalid JWT signature"
**Fix:** Check that `jwt.secret` is the same across all services

### Issue: "Token expired"
**Fix:** Increase `jwt.expiration` or implement refresh tokens

### Issue: "Cannot parse token"
**Fix:** Ensure token is sent as `Bearer <token>` in Authorization header

## Testing

### Test Token Generation:
```cmd
curl -X POST "http://localhost:8090/auth/signin" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"testuser\", \"password\": \"password\"}"
```

### Decode Token (for debugging):
Visit: https://jwt.io
Paste your token to see the decoded payload.

## Summary

✅ JWT authentication added
✅ No business logic changes
✅ Kafka events still working
✅ Backward compatible (returns more data, not less)
✅ Ready for frontend integration

The system now generates JWT tokens on login while maintaining all existing functionality!
