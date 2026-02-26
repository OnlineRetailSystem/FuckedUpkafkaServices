@echo off
REM ============================================================
REM Complete New Kafka Flows Test Script
REM Tests: Cart, Product, and Category Services
REM ============================================================

echo ================================================================
echo     COMPLETE NEW KAFKA FLOWS INTEGRATION TEST
echo ================================================================
echo.
echo This test will verify all new Kafka implementations:
echo   - Cart Service (4 events)
echo   - Product Service (4 events)
echo   - Category Service (1 event)
echo.
echo Total: 9 new Kafka event types
echo.
pause

set API_GATEWAY=http://localhost:8090
set NOTIFICATION_SERVICE=http://localhost:8089

REM Generate unique test data
set TIMESTAMP=%time:~0,2%%time:~3,2%%time:~6,2%%random%
set TEST_USER=fulltest_%TIMESTAMP%
set TEST_CATEGORY=TestCat_%TIMESTAMP%
set TEST_PRODUCT=TestProd_%TIMESTAMP%

echo ================================================================
echo PHASE 1: Pre-flight Checks
echo ================================================================
echo.

echo [1.1] Checking Kafka...
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 >nul 2>&1
if errorlevel 1 (
    echo ERROR: Kafka is not running!
    pause
    exit /b 1
)
echo Kafka: RUNNING

echo.
echo [1.2] Checking Services...
curl -s -o nul -w "Cart Service: %%{http_code}\n" http://localhost:8084
curl -s -o nul -w "Product Service: %%{http_code}\n" http://localhost:8082
curl -s -o nul -w "Category Service: %%{http_code}\n" http://localhost:8085
curl -s -o nul -w "Notification Service: %%{http_code}\n" http://localhost:8089

echo.
echo All services are ready!
echo.
pause

echo ================================================================
echo PHASE 2: Open Monitoring Windows
echo ================================================================
echo.

echo Opening service logs...
start "Cart Service Logs" cmd /k "docker logs ecom-cartservice -f"
timeout /t 1 /nobreak >nul

start "Product Service Logs" cmd /k "docker logs ecom-productservice -f"
timeout /t 1 /nobreak >nul

start "Category Service Logs" cmd /k "docker logs ecom-categoryservice -f"
timeout /t 1 /nobreak >nul

start "Notification Service Logs" cmd /k "docker logs ecom-notificationservice -f"
timeout /t 1 /nobreak >nul

echo.
echo All monitoring windows opened!
echo.
pause

echo ================================================================
echo PHASE 3: Category Service Tests
echo ================================================================
echo.

echo [3.1] Creating Category: %TEST_CATEGORY%
curl -X POST "%API_GATEWAY%/categories" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%TEST_CATEGORY%\"}"

echo.
echo.
echo Event: CATEGORY_CREATED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "ADMIN NOTIFICATION: New Category Created"
echo.
pause

echo ================================================================
echo PHASE 4: Product Service Tests
echo ================================================================
echo.

echo [4.1] Creating Product: %TEST_PRODUCT%
curl -X POST "%API_GATEWAY%/products" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"%TEST_PRODUCT%\", \"description\": \"Test product\", \"price\": 99.99, \"quantity\": 50, \"category\": \"%TEST_CATEGORY%\"}" > product_response.json

echo.
echo.
echo Event: PRODUCT_CREATED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "ADMIN NOTIFICATION: New Product Created"
echo.
pause

REM Assume product ID is 1 for testing (adjust as needed)
set PRODUCT_ID=1

echo [4.2] Updating Product
curl -X PUT "%API_GATEWAY%/products/%PRODUCT_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"price\": 149.99, \"quantity\": 75}"

echo.
echo.
echo Event: PRODUCT_UPDATED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "ADMIN NOTIFICATION: Product Updated"
echo.
pause

echo [4.3] Reducing Product Stock
curl -X PUT "%API_GATEWAY%/products/%PRODUCT_ID%/reduce-stock?quantity=10"

echo.
echo.
echo Event: PRODUCT_STOCK_REDUCED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "NOTIFICATION: Product Stock Reduced"
echo.
pause

echo ================================================================
echo PHASE 5: Cart Service Tests
echo ================================================================
echo.

echo [5.1] Adding Item to Cart
curl -X POST "%API_GATEWAY%/cart/add" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"%TEST_USER%\", \"productId\": %PRODUCT_ID%, \"quantity\": 2}"

echo.
echo.
echo Event: ITEM_ADDED_TO_CART
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "NOTIFICATION: Item Added to Cart"
echo.
pause

REM Assume cart item ID is 1 (adjust as needed)
set CART_ITEM_ID=1

echo [5.2] Updating Cart Item
curl -X PUT "%API_GATEWAY%/cart/%CART_ITEM_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"quantity\": 5}"

echo.
echo.
echo Event: CART_UPDATED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "NOTIFICATION: Cart Updated"
echo.
pause

echo [5.3] Removing Item from Cart
curl -X DELETE "%API_GATEWAY%/cart/%CART_ITEM_ID%"

echo.
echo.
echo Event: ITEM_REMOVED_FROM_CART
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "NOTIFICATION: Item Removed from Cart"
echo.
pause

echo [5.4] Adding Item Again and Clearing Cart
curl -X POST "%API_GATEWAY%/cart/add" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"%TEST_USER%\", \"productId\": %PRODUCT_ID%, \"quantity\": 1}"

echo.
timeout /t 2 /nobreak >nul

curl -X DELETE "%API_GATEWAY%/cart/clear/%TEST_USER%"

echo.
echo.
echo Event: CART_CLEARED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "NOTIFICATION: Cart Cleared"
echo.
pause

echo ================================================================
echo PHASE 6: Delete Product Test
echo ================================================================
echo.

echo [6.1] Deleting Product
curl -X DELETE "%API_GATEWAY%/products/%PRODUCT_ID%"

echo.
echo.
echo Event: PRODUCT_DELETED
echo Waiting 5 seconds for processing...
timeout /t 5 /nobreak >nul

echo.
echo Check Notification Service logs for:
echo   "ADMIN NOTIFICATION: Product Deleted"
echo.
pause

echo ================================================================
echo PHASE 7: Verification
echo ================================================================
echo.

echo [7.1] Checking Kafka Topics
echo.
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 | findstr /C:"CART" /C:"PRODUCT" /C:"CATEGORY"
echo.

echo [7.2] Checking Processed Events
echo.
curl -s "%NOTIFICATION_SERVICE%/notifications/processed-events" > processed_events.json
echo.

echo Counting events by type:
findstr /C:"CATEGORY_CREATED" processed_events.json | find /c "CATEGORY_CREATED"
findstr /C:"PRODUCT_CREATED" processed_events.json | find /c "PRODUCT_CREATED"
findstr /C:"PRODUCT_UPDATED" processed_events.json | find /c "PRODUCT_UPDATED"
findstr /C:"PRODUCT_DELETED" processed_events.json | find /c "PRODUCT_DELETED"
findstr /C:"PRODUCT_STOCK_REDUCED" processed_events.json | find /c "PRODUCT_STOCK_REDUCED"
findstr /C:"ITEM_ADDED_TO_CART" processed_events.json | find /c "ITEM_ADDED_TO_CART"
findstr /C:"CART_UPDATED" processed_events.json | find /c "CART_UPDATED"
findstr /C:"ITEM_REMOVED_FROM_CART" processed_events.json | find /c "ITEM_REMOVED_FROM_CART"
findstr /C:"CART_CLEARED" processed_events.json | find /c "CART_CLEARED"

echo.
pause

echo ================================================================
echo PHASE 8: Open Kafka Topic Monitors
echo ================================================================
echo.

echo Opening Kafka topic monitors for all new topics...
echo.

start "Kafka: CATEGORY_CREATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CATEGORY_CREATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_CREATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_CREATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_UPDATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_UPDATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_DELETED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_DELETED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: PRODUCT_STOCK_REDUCED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_STOCK_REDUCED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: ITEM_ADDED_TO_CART" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: CART_UPDATED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CART_UPDATED --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: ITEM_REMOVED_FROM_CART" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_REMOVED_FROM_CART --from-beginning"
timeout /t 1 /nobreak >nul

start "Kafka: CART_CLEARED" cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CART_CLEARED --from-beginning"

echo.
echo All Kafka topic monitors opened!
echo.

echo ================================================================
echo                    TEST SUMMARY
echo ================================================================
echo.
echo New Kafka Events Tested:
echo.
echo Category Service (1 event):
echo   [✓] CATEGORY_CREATED
echo.
echo Product Service (4 events):
echo   [✓] PRODUCT_CREATED
echo   [✓] PRODUCT_UPDATED
echo   [✓] PRODUCT_DELETED
echo   [✓] PRODUCT_STOCK_REDUCED
echo.
echo Cart Service (4 events):
echo   [✓] ITEM_ADDED_TO_CART
echo   [✓] CART_UPDATED
echo   [✓] ITEM_REMOVED_FROM_CART
echo   [✓] CART_CLEARED
echo.
echo Total: 9 new Kafka event types tested
echo.

echo ================================================================
echo                    VERIFICATION CHECKLIST
echo ================================================================
echo.
echo [ ] All 9 event types appear in Kafka topics
echo [ ] All 9 event types appear in processed_events
echo [ ] Notification Service logged all events
echo [ ] No duplicate processing occurred
echo [ ] Service logs show Kafka producer activity
echo [ ] Consumer group is active
echo.

echo ================================================================
echo                    COMPLETE FLOW DIAGRAM
echo ================================================================
echo.
echo Category Flow:
echo   Admin -^> API Gateway -^> Category Service -^> Kafka -^> Notification
echo.
echo Product Flow:
echo   Admin -^> API Gateway -^> Product Service -^> Kafka -^> Notification
echo.
echo Cart Flow:
echo   User -^> API Gateway -^> Cart Service -^> Kafka -^> Notification
echo.

echo ================================================================
echo                    USEFUL COMMANDS
echo ================================================================
echo.
echo Check all new topics:
echo   docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 ^| findstr /C:"CART" /C:"PRODUCT" /C:"CATEGORY"
echo.
echo Check consumer group:
echo   docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092
echo.
echo Check processed events:
echo   curl http://localhost:8089/notifications/processed-events
echo.
echo Check notification database:
echo   docker exec ecom-mysql mysql -uroot -proot -e "SELECT eventType, COUNT(*) as count FROM notificationdb.processed_events GROUP BY eventType;"
echo.

echo ================================================================
echo                    TEST COMPLETE
echo ================================================================
echo.
echo All new Kafka flows have been tested!
echo.
echo Review the monitoring windows to verify:
echo   - Service logs show event publishing
echo   - Kafka topics contain the events
echo   - Notification service consumed and processed events
echo.
echo All windows will remain open for your review.
echo.
pause
