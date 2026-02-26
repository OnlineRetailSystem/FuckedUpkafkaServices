@echo off
REM ============================================================
REM Create Admin User with JWT (WITHOUT DOCKER)
REM ============================================================

echo ================================================================
echo          CREATING ADMIN USER WITH JWT SUPPORT (NO DOCKER)
echo ================================================================
echo.

echo PREREQUISITES:
echo   1. Make sure MySQL is running on your machine
echo   2. Auth service should be running on http://localhost:8090
echo   3. You need 'mysql' command available in PATH
echo.
echo If you don't have mysql command, install:
echo   - MySQL Community Server (includes mysql CLI)
echo   - Or add MySQL bin folder to your PATH
echo.
pause

echo.
echo Step 1: Creating admin user via signup API...
echo.

curl -X POST "http://localhost:8090/auth/signup" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"admin\", \"password\": \"admin12345\", \"email\": \"admin@ecom.com\", \"firstName\": \"Admin\", \"lastName\": \"User\"}"

echo.
echo.

echo Step 2: Updating user role to ADMIN in database...
echo.
echo Attempting to connect to local MySQL...
echo.

REM Replace with your MySQL credentials
REM Default values - modify if your MySQL setup is different:
REM   Host: localhost
REM   Port: 3306
REM   User: root
REM   Password: root
REM   Database: authservice

mysql -h localhost -u root -proot -e "UPDATE authservice.users SET roles='ROLE_ADMIN' WHERE username='admin';"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Could not connect to MySQL!
    echo.
    echo Make sure:
    echo   1. MySQL is running
    echo   2. Username and password are correct (default: root/root)
    echo   3. Database 'authservice' exists
    echo.
    echo If you need different credentials, edit this script and update:
    echo   - Host
    echo   - User (-u)
    echo   - Password (-p)
    echo.
    pause
    exit /b 1
)

echo.
echo Step 3: Testing admin login with JWT...
echo.

timeout /t 2

curl -X POST "http://localhost:8090/auth/signin" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"admin\", \"password\": \"admin12345\"}"

echo.
echo.

echo ================================================================
echo          ADMIN USER CREATED SUCCESSFULLY
echo ================================================================
echo.
echo Admin can now login and receive JWT token!
echo.
echo Credentials:
echo   Username: admin
echo   Password: admin12345
echo   Email: admin@ecom.com
echo.
echo Roles: ROLE_ADMIN
echo.
echo The JWT token will include ROLE_ADMIN in the roles claim.
echo.
echo To verify in MySQL directly:
echo   mysql -h localhost -u root -proot
echo   USE authservice;
echo   SELECT username, email, roles FROM users WHERE username='admin';
echo.
pause
