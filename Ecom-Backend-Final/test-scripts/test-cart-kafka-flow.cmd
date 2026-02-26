@echo off
REM ============================================================
REM Cart Service Kafka Event Flow Test Script
REM Tests: Cart Service -> Kafka -> Notification Service
REM ============================================================

echo ================================================================
echo          CART SERVICE KAFKA EVENT FLOW TEST
echo ================================================================
echo.

set API_GATEWAY=http://localhost:8090
set CART_SERVICE=http://localhost:8084
set NOTIFICATION_SERVICE=http://localhost:8089

set TESTS_PASSED=0
set TESTS_FAILED=0

REM Generate unique test data
set TIMESTAMP=%time:~0,2%%time:~3,2%%time:~6,2%%random%
set TEST_USER=carttest_%TIMESTAMP%

echo ================================================================
echo PRE-TEST: Setup
echo ================================================================
echo.
echo Test User: %TEST_USER%
echo.

REM Assume we have a product with ID 1 (you may need to create one first)
set PRODUCT_ID=1
set PRODUCT_NAME=Test Product
set QUANTITY=2
set PRICE=99.99

echo ================================================================
echo TEST 1: Add Item to Cart (ITEM_ADDED_TO_CART Event)
echo ================================================================
echo Testing: Cart Service -^> Kafka -^> Notification Service
echo.

echo Adding item to cart...
curl -X POST "%API_GATEWAY%/cart/add" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"%TEST_USER%\", \"productId\": %PRODUCT_ID%, \"quantity\": %QUANTITY%}"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "NOTIFICATION: Item Added to Cart"
echo   - User: %TEST_USER%
echo   - Product: %PRODUCT_NAME%
echo.

echo To verify, check logs:
echo   docker logs ecom-notificationservice --tail 20
echo.
pause

echo ================================================================
echo TEST 2: Update Cart Item (CART_UPDATED Event)
echo ================================================================
echo.

echo Getting cart items to find item ID...
curl -s "%API_GATEWAY%/cart/%TEST_USER%" > cart_items.json
echo.

REM In real scenario, parse JSON to get item ID. For now, assume ID 1
set CART_ITEM_ID=1

echo Updating cart item quantity to 5...
curl -X PUT "%API_GATEWAY%/cart/%CART_ITEM_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"quantity\": 5}"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "NOTIFICATION: Cart Updated"
echo   - User: %TEST_USER%
echo   - New Quantity: 5
echo.
pause

echo ================================================================
echo TEST 3: Remove Item from Cart (ITEM_REMOVED_FROM_CART Event)
echo ================================================================
echo.

echo Removing item from cart...
curl -X DELETE "%API_GATEWAY%/cart/%CART_ITEM_ID%"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "NOTIFICATION: Item Removed from Cart"
echo   - User: %TEST_USER%
echo.
pause

echo ================================================================
echo TEST 4: Clear Cart (CART_CLEARED Event)
echo ================================================================
echo.

REM Add item again for clearing test
echo Adding item back to cart...
curl -X POST "%API_GATEWAY%/cart/add" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"%TEST_USER%\", \"productId\": %PRODUCT_ID%, \"quantity\": 1}"

echo.
timeout /t 2 /nobreak >nul

echo Clearing entire cart...
curl -X DELETE "%API_GATEWAY%/cart/clear/%TEST_USER%"

echo.
echo.
echo Waiting for Kafka event processing (5 seconds)...
timeout /t 5 /nobreak >nul

echo.
echo Expected in Notification Service logs:
echo   - "NOTIFICATION: Cart Cleared"
echo   - User: %TEST_USER%
echo.
pause

echo ================================================================
echo TEST 5: Verify Processed Events
echo ================================================================
echo.

echo Checking processed events in notification service...
curl -s "%NOTIFICATION_SERVICE%/notifications/processed-events" | findstr /C:"ITEM_ADDED_TO_CART" /C:"CART_UPDATED" /C:"ITEM_REMOVED_FROM_CART" /C:"CART_CLEARED"

echo.
echo.

echo ================================================================
echo TEST 6: Monitor Kafka Topics
echo ================================================================
echo.

echo Opening Kafka topic monitors...
echo.

start "Kafka: ITEM_ADDED_TO_CART" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: CART_UPDATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CART_UPDATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: ITEM_REMOVED_FROM_CART" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_REMOVED_FROM_CART --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: CART_CLEARED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CART_CLEARED --from-beginning"

echo.
echo Kafka topic monitors opened!
echo Review the messages in each window.
echo.

echo ================================================================
echo                    TEST SUMMARY
echo ================================================================
echo.
echo Cart Service Kafka Events Tested:
echo   [1] ITEM_ADDED_TO_CART
echo   [2] CART_UPDATED
echo   [3] ITEM_REMOVED_FROM_CART
echo   [4] CART_CLEARED
echo.
echo Verification Steps:
echo   1. Check Cart Service logs:
echo      docker logs ecom-cartservice --tail 50
echo.
echo   2. Check Notification Service logs:
echo      docker logs ecom-notificationservice --tail 50
echo.
echo   3. Check Kafka topics:
echo      docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 ^| findstr CART
echo.
echo   4. Check processed events:
echo      curl http://localhost:8089/notifications/processed-events
echo.

echo ================================================================
echo                    FLOW DIAGRAM
echo ================================================================
echo.
echo Cart Service Flow:
echo.
echo    User Action (Add/Update/Remove/Clear)
echo       │
echo       ▼
echo    API Gateway (8090)
echo       │
echo       ▼
echo    Cart Service (8084)
echo       │
echo       ├─► MySQL (Save cart data)
echo       │
echo       └─► Kafka Producer (CartEventProducer)
echo              │
echo              ▼
echo           Kafka Topics:
echo              - ITEM_ADDED_TO_CART
echo              - CART_UPDATED
echo              - ITEM_REMOVED_FROM_CART
echo              - CART_CLEARED
echo              │
echo              ▼
echo           Kafka Consumer
echo              │
echo              ▼
echo    Notification Service (8089)
echo       │
echo       ├─► Check idempotency
echo       ├─► Log notification
echo       └─► Save to processed_events
echo.

echo ================================================================
echo                    TEST COMPLETE
echo ================================================================
echo.
pause
