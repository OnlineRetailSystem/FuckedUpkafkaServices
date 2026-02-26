@echo off
REM ============================================================
REM Create Admin User for JWT Authentication
REM ============================================================

echo ================================================================
echo          CREATING ADMIN USER WITH JWT SUPPORT
echo ================================================================
echo.

echo This will create an admin user:
echo   Username: admin
echo   Password: admin12345
echo   Email: admin@ecom.com
echo   Roles: ROLE_ADMIN
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

docker exec ecom-mysql mysql -uroot -proot -e "UPDATE authservice.users SET roles='ROLE_ADMIN' WHERE username='admin';"

echo.
echo.

echo Step 3: Testing admin login with JWT...
echo.

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
echo.
echo The JWT token will include ROLE_ADMIN in the roles claim.
echo.
pause
