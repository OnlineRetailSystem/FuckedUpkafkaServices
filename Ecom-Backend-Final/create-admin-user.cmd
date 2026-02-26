@echo off
REM ============================================================
REM Create Admin User in Database
REM ============================================================

echo ================================================================
echo          CREATING ADMIN USER
echo ================================================================
echo.

echo This will create an admin user with:
echo   Username: admin
echo   Password: admin123
echo   Email: admin@ecom.com
echo   Roles: ROLE_ADMIN
echo.
pause

echo.
echo Creating admin user via API...
echo.

curl -X POST "http://localhost:8090/auth/signup" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"admin\", \"password\": \"admin123\", \"email\": \"admin@ecom.com\", \"firstName\": \"Admin\", \"lastName\": \"User\"}"

echo.
echo.

echo Updating user role to ADMIN in database...
echo.

docker exec ecom-mysql mysql -uroot -proot -e "UPDATE authservice.users SET roles='ROLE_ADMIN' WHERE username='admin';"

echo.
echo.

echo ================================================================
echo          ADMIN USER CREATED SUCCESSFULLY
echo ================================================================
echo.
echo Admin Credentials:
echo   Username: admin
echo   Password: admin123
echo.
echo You can now login at: http://localhost:3000/adminlogin
echo.
echo To verify admin user:
echo   docker exec ecom-mysql mysql -uroot -proot -e "SELECT username, email, roles FROM authservice.users WHERE username='admin';"
echo.
pause
