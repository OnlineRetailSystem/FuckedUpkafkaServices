# Create Admin User WITHOUT Docker

## Overview
If you don't have Docker running, you can still create an admin user by:
1. Calling the auth service API directly
2. Updating the MySQL database using the MySQL CLI (instead of docker exec)

---

## Prerequisites

### 1. MySQL Server Running
You need MySQL installed and running on your machine:

**Install MySQL:**
- Download: https://dev.mysql.com/downloads/mysql/
- Windows: MySQL Community Server
- During installation, remember your root password

**Verify MySQL is running:**
```cmd
mysql -h localhost -u root -proot -e "SELECT VERSION();"
```

### 2. Auth Service Running Locally
You need to start the auth service locally (without Docker):

```cmd
cd authservice
mvn clean install
mvn spring-boot:run
```

Wait for it to start on `http://localhost:8090`

### 3. MySQL CLI in PATH
Make sure `mysql` command is available in your PATH.

**To add MySQL to PATH:**
1. Find your MySQL installation (usually `C:\Program Files\MySQL\MySQL Server 8.0\bin`)
2. Add it to Windows PATH:
   - Right-click "This PC" → Properties
   - Advanced system settings → Environment Variables
   - Edit PATH and add MySQL bin folder

**Test:**
```cmd
mysql --version
```

---

## Steps to Create Admin User

### Option 1: Using the Provided Script

Run the non-Docker script:
```cmd
create-admin-no-docker.cmd
```

**What it does:**
1. Calls `/auth/signup` API to create user
2. Updates database directly with MySQL CLI to set role to ADMIN
3. Tests login to verify JWT is working

### Option 2: Manual Steps

#### Step 1: Create User via API
```cmd
curl -X POST "http://localhost:8090/auth/signup" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"admin\", \"password\": \"admin12345\", \"email\": \"admin@ecom.com\", \"firstName\": \"Admin\", \"lastName\": \"User\"}"
```

#### Step 2: Update Role to ADMIN
```cmd
mysql -h localhost -u root -proot -e "UPDATE authservice.users SET roles='ROLE_ADMIN' WHERE username='admin';"
```

#### Step 3: Test Login with JWT
```cmd
curl -X POST "http://localhost:8090/auth/signin" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"admin\", \"password\": \"admin12345\"}"
```

**You should see a response with JWT token:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "admin",
  "email": "admin@ecom.com",
  "roles": "ROLE_ADMIN",
  "message": "Login successful"
}
```

---

## Troubleshooting

### "mysql command not found"
**Solution:** Add MySQL bin folder to PATH
- Find MySQL installation folder
- Add `C:\Program Files\MySQL\MySQL Server 8.0\bin` to Windows PATH
- Restart terminal

### "Access denied for user 'root'@'localhost'"
**Solution:** Check your MySQL password
- Your password is not `root` (default during installation)
- Edit the script or command to use correct password
- Example: `mysql -h localhost -u root -p[YOUR_PASSWORD]`

### "Can't connect to MySQL server"
**Solution:** 
- Start MySQL service:
  - Windows Services → MySQL80 → Start
  - Or: `net start MySQL80`
- Check if it's running:
  - `mysql -h localhost -u root -proot -e "SELECT 1;"`

### "Unknown database 'authservice'"
**Solution:**
1. The auth service needs to create the database on first run
2. Make sure auth service started successfully
3. Check logs for errors

### "Auth service not responding on localhost:8090"
**Solution:**
1. Make sure auth service is running: `mvn spring-boot:run` from authservice folder
2. Check if it started without errors
3. Try: `curl http://localhost:8090/auth/health`

---

## Modify Credentials

If you want different username/password, edit the script or commands.

**Change in script:**
Find these lines and change values:
```
username: "admin" → "yourusername"
password: "admin12345" → "yourpassword"
email: "admin@ecom.com" → "youremail@example.com"
```

**Change database credentials in script:**
Find this line:
```
mysql -h localhost -u root -proot
```

Change to your credentials:
```
mysql -h [HOST] -u [USERNAME] -p[PASSWORD]
```

Example with different password:
```
mysql -h localhost -u root -pMySecurePassword123
```

---

## Verify Admin User

Check admin user was created:
```cmd
mysql -h localhost -u root -proot -e "SELECT username, email, roles FROM authservice.users WHERE username='admin';"
```

You should see:
```
admin | admin@ecom.com | ROLE_ADMIN
```

---

## What is JWT?

JWT (JSON Web Token) is a secure way to authenticate users:
1. User logs in with username/password
2. Server returns a JWT token
3. Client sends token in header for protected requests
4. Server validates token instead of checking database each time

The admin JWT token will have:
- Username: admin
- Roles: ROLE_ADMIN
- Valid for: 24 hours (default)

---

## Next Steps

Once admin user is created:
1. Use the JWT token to access protected endpoints
2. Include token in Authorization header:
   ```
   Authorization: Bearer [JWT_TOKEN_HERE]
   ```
3. Create other users via API
4. Use admin role for admin-only operations
