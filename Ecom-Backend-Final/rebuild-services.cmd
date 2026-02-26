@echo off
REM ============================================================
REM Rebuild Services with New Kafka Implementation
REM ============================================================

echo ================================================================
echo          REBUILDING SERVICES WITH KAFKA UPDATES
echo ================================================================
echo.
echo This will rebuild the following services:
echo   - Cart Service
echo   - Product Service
echo   - Category Service
echo   - Notification Service
echo.
echo This may take 5-10 minutes...
echo.
pause

echo ================================================================
echo Step 1: Stopping Services
echo ================================================================
echo.

docker-compose stop cartservice productservice categoryservice notificationservice

echo.
echo Services stopped.
echo.

echo ================================================================
echo Step 2: Rebuilding Services
echo ================================================================
echo.

echo Rebuilding Cart Service...
docker-compose build cartservice
echo.

echo Rebuilding Product Service...
docker-compose build productservice
echo.

echo Rebuilding Category Service...
docker-compose build categoryservice
echo.

echo Rebuilding Notification Service...
docker-compose build notificationservice
echo.

echo ================================================================
echo Step 3: Starting Services
echo ================================================================
echo.

docker-compose up -d cartservice productservice categoryservice notificationservice

echo.
echo Services started!
echo.

echo ================================================================
echo Step 4: Waiting for Services to Start (30 seconds)
echo ================================================================
echo.

timeout /t 30 /nobreak

echo ================================================================
echo Step 5: Checking Service Status
echo ================================================================
echo.

docker ps | findstr "cart\|product\|category\|notification"

echo.

echo ================================================================
echo Step 6: Checking Service Logs
echo ================================================================
echo.

echo Cart Service logs:
docker logs ecom-cartservice --tail 10
echo.

echo Product Service logs:
docker logs ecom-productservice --tail 10
echo.

echo Category Service logs:
docker logs ecom-categoryservice --tail 10
echo.

echo Notification Service logs:
docker logs ecom-notificationservice --tail 10
echo.

echo ================================================================
echo                    REBUILD COMPLETE
echo ================================================================
echo.
echo Services have been rebuilt with Kafka support!
echo.
echo Next steps:
echo   1. Test category creation: curl -X POST "http://localhost:8090/categories" -H "Content-Type: application/json" -d "{\"name\": \"Electronics\"}"
echo   2. Check logs: docker logs ecom-categoryservice --tail 20
echo   3. Check notifications: docker logs ecom-notificationservice --tail 20
echo.
pause
