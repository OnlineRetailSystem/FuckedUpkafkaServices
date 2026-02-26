@echo off
REM ============================================================
REM Product Service Kafka Event Flow Test Script
REM Tests: Product Service -> Kafka -> Notification Service
REM ============================================================

echo ================================================================
echo          PRODUCT SERVICE KAFKA EVENT FLOW TEST
echo ================================================================
echo.

set API_GATEWAY=http://localhost:8090
set PRODUCT_SERVICE=http://localhost:8082
set NOTIFICATION_SERVICE=http://localhost:8089

set TESTS_PASSED=0
set TESTS_FAILED=0

REM Generate unique test data
set TIMESTAMP=%time:~0,2%%time:~3,2%%time:~6,2%%random%
set TEST_PRODUCT=TestProduct_%TIMESTAMP%

echo ================================================================
echo PRE-TEST: Setup
echo ================================================================
echo.
echo Test Product: %TEST_PRODUCT%
echo.

echo ================================================================
echo TEST 1: Create Product (PRODUCT_CREATED Event)
echo ================================================================
echo Testing: Product Service -^> Kafka -^> Notification Service
echo.

echo Creating new product...
curl -X POST "%API_GATEWAY%/products" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%TEST_PRODUCT%\", \"description\": \"Test product for Kafka\", \"price\": 199.99, \"quantity\": 100, \"category\": \"Electronics\"}" > product_response.json

echo.
echo.

REM Extract product ID from response (simplified - in real scenario parse JSON)
echo Product created! Check response for ID.
type product_response.json
echo.

echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "ADMIN NOTIFICATION: New Product Created"
echo   - Product: %TEST_PRODUCT%
echo   - Category: Electronics
echo   - Price: $199.99
echo.

echo To verify, check logs:
echo   docker logs ecom-notificationservice --tail 20
echo.
pause

REM For subsequent tests, we'll use a product ID (you may need to adjust this)
set PRODUCT_ID=1

echo ================================================================
echo TEST 2: Update Product (PRODUCT_UPDATED Event)
echo ================================================================
echo.

echo Updating product details...
curl -X PUT "%API_GATEWAY%/products/%PRODUCT_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%TEST_PRODUCT%_Updated\", \"price\": 249.99, \"quantity\": 150}"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "ADMIN NOTIFICATION: Product Updated"
echo   - Product: %TEST_PRODUCT%_Updated
echo.
pause

echo ================================================================
echo TEST 3: Reduce Stock (PRODUCT_STOCK_REDUCED Event)
echo ================================================================
echo.

echo Reducing product stock by 10 units...
curl -X PUT "%API_GATEWAY%/products/%PRODUCT_ID%/reduce-stock?quantity=10"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "NOTIFICATION: Product Stock Reduced"
echo   - Product: %TEST_PRODUCT%_Updated
echo   - Remaining Stock: 140
echo.
pause

echo ================================================================
echo TEST 4: Delete Product (PRODUCT_DELETED Event)
echo ================================================================
echo.

echo Deleting product...
curl -X DELETE "%API_GATEWAY%/products/%PRODUCT_ID%"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "ADMIN NOTIFICATION: Product Deleted"
echo   - Product: %TEST_PRODUCT%_Updated
echo.
pause

echo ================================================================
echo TEST 5: Verify Processed Events
echo ================================================================
echo.

echo Checking processed events in notification service...
curl -s "%NOTIFICATION_SERVICE%/notifications/processed-events" | findstr /C:"PRODUCT_CREATED" /C:"PRODUCT_UPDATED" /C:"PRODUCT_DELETED" /C:"PRODUCT_STOCK_REDUCED"

echo.
echo.

echo ================================================================
echo TEST 6: Monitor Kafka Topics
echo ================================================================
echo.

echo Opening Kafka topic monitors...
echo.

start "Kafka: PRODUCT_CREATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_CREATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_UPDATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_UPDATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_DELETED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_DELETED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_STOCK_REDUCED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_STOCK_REDUCED --from-beginning"

echo.
echo Kafka topic monitors opened!
echo Review the messages in each window.
echo.

echo ================================================================
echo                    TEST SUMMARY
echo ================================================================
echo.
echo Product Service Kafka Events Tested:
echo   [1] PRODUCT_CREATED
echo   [2] PRODUCT_UPDATED
echo   [3] PRODUCT_STOCK_REDUCED
echo   [4] PRODUCT_DELETED
echo.
echo Verification Steps:
echo   1. Check Product Service logs:
echo      docker logs ecom-productservice --tail 50
echo.
echo   2. Check Notification Service logs:
echo      docker logs ecom-notificationservice --tail 50
echo.
echo   3. Check Kafka topics:
echo      docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 ^| findstr PRODUCT
echo.
echo   4. Check processed events:
echo      curl http://localhost:8089/notifications/processed-events
echo.

echo ================================================================
echo                    FLOW DIAGRAM
echo ================================================================
echo.
echo Product Service Flow:
echo.
echo    Admin Action (Create/Update/Delete/Reduce Stock)
echo       │
echo       ▼
echo    API Gateway (8090)
echo       │
echo       ▼
echo    Product Service (8082)
echo       │
echo       ├─► MySQL (Save product data)
echo       │
echo       └─► Kafka Producer (ProductEventProducer)
echo              │
echo              ▼
echo           Kafka Topics:
echo              - PRODUCT_CREATED
echo              - PRODUCT_UPDATED
echo              - PRODUCT_DELETED
echo              - PRODUCT_STOCK_REDUCED
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
pause
