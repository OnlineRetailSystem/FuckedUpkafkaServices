@echo off
REM ============================================================
REM Category Service Kafka Event Flow Test Script
REM Tests: Category Service -> Kafka -> Notification Service
REM ============================================================

echo ================================================================
echo          CATEGORY SERVICE KAFKA EVENT FLOW TEST
echo ================================================================
echo.

set API_GATEWAY=http://localhost:8090
set CATEGORY_SERVICE=http://localhost:8085
set NOTIFICATION_SERVICE=http://localhost:8089

set TESTS_PASSED=0
set TESTS_FAILED=0

REM Generate unique test data
set TIMESTAMP=%time:~0,2%%time:~3,2%%time:~6,2%%random%
set TEST_CATEGORY=TestCategory_%TIMESTAMP%

echo ================================================================
echo PRE-TEST: Setup
echo ================================================================
echo.
echo Test Category: %TEST_CATEGORY%
echo.

echo ================================================================
echo TEST 1: Create Category (CATEGORY_CREATED Event)
echo ================================================================
echo Testing: Category Service -^> Kafka -^> Notification Service
echo.

echo Creating new category...
curl -X POST "%API_GATEWAY%/categories" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%TEST_CATEGORY%\"}" > category_response.json

echo.
echo.

echo Category created! Check response:
type category_response.json
echo.

echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "ADMIN NOTIFICATION: New Category Created"
echo   - Category: %TEST_CATEGORY%
echo.

echo To verify, check logs:
echo   docker logs ecom-notificationservice --tail 20
echo.
pause

echo ================================================================
echo TEST 2: Create Multiple Categories
echo ================================================================
echo.

echo Creating additional categories to test multiple events...
echo.

set CATEGORY_2=Electronics_%TIMESTAMP%
set CATEGORY_3=Clothing_%TIMESTAMP%
set CATEGORY_4=Books_%TIMESTAMP%

echo Creating category: %CATEGORY_2%
curl -X POST "%API_GATEWAY%/categories" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%CATEGORY_2%\"}"

echo.
timeout /t 2 /nobreak >nul

echo Creating category: %CATEGORY_3%
curl -X POST "%API_GATEWAY%/categories" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%CATEGORY_3%\"}"

echo.
timeout /t 2 /nobreak >nul

echo Creating category: %CATEGORY_4%
curl -X POST "%API_GATEWAY%/categories" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%CATEGORY_4%\"}"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected: 3 more CATEGORY_CREATED events in notification logs
echo.
pause

echo ================================================================
echo TEST 3: Verify All Categories Created
echo ================================================================
echo.

echo Fetching all categories...
curl -s "%API_GATEWAY%/categories"

echo.
echo.

echo ================================================================
echo TEST 4: Verify Processed Events
echo ================================================================
echo.

echo Checking processed events in notification service...
curl -s "%NOTIFICATION_SERVICE%/notifications/processed-events" | findstr /C:"CATEGORY_CREATED"

echo.
echo.
echo Expected: At least 4 CATEGORY_CREATED events
echo.
pause

echo ================================================================
echo TEST 5: Monitor Kafka Topic
echo ================================================================
echo.

echo Opening Kafka topic monitor...
echo.

start "Kafka: CATEGORY_CREATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CATEGORY_CREATED --from-beginning"

echo.
echo Kafka topic monitor opened!
echo Review the messages in the window.
echo.
timeout /t 2 /nobreak >nul

echo ================================================================
echo TEST 6: Check Topic Details
echo ================================================================
echo.

echo Checking CATEGORY_CREATED topic details...
docker exec ecom-kafka kafka-topics --describe --topic CATEGORY_CREATED --bootstrap-server localhost:9092

echo.

echo ================================================================
echo                    TEST SUMMARY
echo ================================================================
echo.
echo Category Service Kafka Events Tested:
echo   [1] CATEGORY_CREATED (4 events)
echo.
echo Categories Created:
echo   - %TEST_CATEGORY%
echo   - %CATEGORY_2%
echo   - %CATEGORY_3%
echo   - %CATEGORY_4%
echo.
echo Verification Steps:
echo   1. Check Category Service logs:
echo      docker logs ecom-categoryservice --tail 50
echo.
echo   2. Check Notification Service logs:
echo      docker logs ecom-notificationservice --tail 50
echo.
echo   3. Check Kafka topic:
echo      docker exec ecom-kafka kafka-topics --describe --topic CATEGORY_CREATED --bootstrap-server localhost:9092
echo.
echo   4. Check processed events:
echo      curl http://localhost:8089/notifications/processed-events
echo.
echo   5. List all categories:
echo      curl http://localhost:8090/categories
echo.

echo ================================================================
echo                    FLOW DIAGRAM
echo ================================================================
echo.
echo Category Service Flow:
echo.
echo    Admin Action (Create Category)
echo       │
echo       ▼
echo    API Gateway (8090)
echo       │
echo       ▼
echo    Category Service (8085)
echo       │
echo       ├─► MySQL (Save category data)
echo       │
echo       └─► Kafka Producer (CategoryEventProducer)
echo              │
echo              ▼
echo           Kafka Topic:
echo              - CATEGORY_CREATED
echo              │
echo              ▼
echo           Kafka Consumer
echo              │
echo              ▼
echo    Notification Service (8089)
echo       │
echo       ├─► Check idempotency
echo       ├─► Log admin notification
echo       └─► Save to processed_events
echo.

echo ================================================================
echo                    TEST COMPLETE
echo ================================================================
echo.
echo All category Kafka events have been tested!
echo.
pause
