@echo off
REM ============================================================
REM Kafka Topics Verification Script
REM Checks if Kafka topics are created and accessible
REM ============================================================

echo ================================================================
echo          KAFKA TOPICS VERIFICATION TEST
echo ================================================================
echo.

echo [TEST 1] Checking if Kafka container is running...
docker ps --filter "name=ecom-kafka" --format "{{.Names}} - {{.Status}}"
if errorlevel 1 (
    echo ERROR: Kafka container is not running!
    echo Please start services: docker-compose up -d
    pause
    exit /b 1
)
echo.

echo [TEST 2] Listing all Kafka topics...
echo.
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092
if errorlevel 1 (
    echo ERROR: Cannot connect to Kafka!
    pause
    exit /b 1
)
echo.

echo [TEST 3] Checking for expected topics...
echo.
echo Expected topics (Existing):
echo   - USER_REGISTERED
echo   - USER_LOGGED_IN
echo   - PAYMENT_SUCCESS
echo   - ORDER_PLACED
echo   - ORDER_STATUS_UPDATED
echo   - LOW_STOCK_ALERT
echo.
echo Expected topics (New - Cart Service):
echo   - ITEM_ADDED_TO_CART
echo   - ITEM_REMOVED_FROM_CART
echo   - CART_UPDATED
echo   - CART_CLEARED
echo.
echo Expected topics (New - Product Service):
echo   - PRODUCT_CREATED
echo   - PRODUCT_UPDATED
echo   - PRODUCT_DELETED
echo   - PRODUCT_STOCK_REDUCED
echo.
echo Expected topics (New - Category Service):
echo   - CATEGORY_CREATED
echo.

set TOPICS_FOUND=0
set TOTAL_TOPICS=15

docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092 > temp_topics.txt 2>&1

REM Existing topics
findstr /C:"USER_REGISTERED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] USER_REGISTERED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] USER_REGISTERED
)

findstr /C:"USER_LOGGED_IN" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] USER_LOGGED_IN
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] USER_LOGGED_IN
)

findstr /C:"PAYMENT_SUCCESS" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] PAYMENT_SUCCESS
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] PAYMENT_SUCCESS
)

findstr /C:"ORDER_PLACED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] ORDER_PLACED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] ORDER_PLACED
)

findstr /C:"ORDER_STATUS_UPDATED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] ORDER_STATUS_UPDATED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] ORDER_STATUS_UPDATED
)

findstr /C:"LOW_STOCK_ALERT" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] LOW_STOCK_ALERT
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] LOW_STOCK_ALERT
)

REM New Cart Service topics
findstr /C:"ITEM_ADDED_TO_CART" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] ITEM_ADDED_TO_CART
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] ITEM_ADDED_TO_CART
)

findstr /C:"ITEM_REMOVED_FROM_CART" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] ITEM_REMOVED_FROM_CART
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] ITEM_REMOVED_FROM_CART
)

findstr /C:"CART_UPDATED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] CART_UPDATED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] CART_UPDATED
)

findstr /C:"CART_CLEARED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] CART_CLEARED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] CART_CLEARED
)

REM New Product Service topics
findstr /C:"PRODUCT_CREATED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] PRODUCT_CREATED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] PRODUCT_CREATED
)

findstr /C:"PRODUCT_UPDATED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] PRODUCT_UPDATED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] PRODUCT_UPDATED
)

findstr /C:"PRODUCT_DELETED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] PRODUCT_DELETED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] PRODUCT_DELETED
)

findstr /C:"PRODUCT_STOCK_REDUCED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] PRODUCT_STOCK_REDUCED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] PRODUCT_STOCK_REDUCED
)

REM New Category Service topics
findstr /C:"CATEGORY_CREATED" temp_topics.txt >nul
if %errorlevel%==0 (
    echo [FOUND] CATEGORY_CREATED
    set /a TOPICS_FOUND+=1
) else (
    echo [MISSING] CATEGORY_CREATED
)

del temp_topics.txt

echo.
echo Topics found: %TOPICS_FOUND% / %TOTAL_TOPICS%
echo.

if %TOPICS_FOUND% LSS %TOTAL_TOPICS% (
    echo NOTE: Some topics are missing. They will be auto-created when first used.
    echo This is normal if no events have been published yet.
)

echo.
echo [TEST 4] Getting topic details...
echo.

echo --- USER_REGISTERED Topic Details ---
docker exec ecom-kafka kafka-topics --describe --topic USER_REGISTERED --bootstrap-server localhost:9092 2>nul
if errorlevel 1 (
    echo Topic not created yet. Will be auto-created on first event.
)
echo.

echo --- USER_LOGGED_IN Topic Details ---
docker exec ecom-kafka kafka-topics --describe --topic USER_LOGGED_IN --bootstrap-server localhost:9092 2>nul
if errorlevel 1 (
    echo Topic not created yet. Will be auto-created on first event.
)
echo.

echo [TEST 5] Checking Kafka consumer groups...
echo.
docker exec ecom-kafka kafka-consumer-groups --list --bootstrap-server localhost:9092
echo.

echo [TEST 6] Checking notification-service-group details...
echo.
docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092 2>nul
if errorlevel 1 (
    echo Consumer group not active yet. Will be created when notification service starts consuming.
)
echo.

echo ================================================================
echo                    SUMMARY
echo ================================================================
echo.
echo Kafka Status: RUNNING
echo Topics Found: %TOPICS_FOUND% / %TOTAL_TOPICS%
echo.
echo To trigger topic creation:
echo   Auth Service:
echo     1. Register a user (creates USER_REGISTERED topic)
echo     2. Login (creates USER_LOGGED_IN topic)
echo.
echo   Cart Service:
echo     3. Add item to cart (creates ITEM_ADDED_TO_CART topic)
echo     4. Update cart (creates CART_UPDATED topic)
echo     5. Remove item (creates ITEM_REMOVED_FROM_CART topic)
echo     6. Clear cart (creates CART_CLEARED topic)
echo.
echo   Product Service:
echo     7. Create product (creates PRODUCT_CREATED topic)
echo     8. Update product (creates PRODUCT_UPDATED topic)
echo     9. Delete product (creates PRODUCT_DELETED topic)
echo     10. Reduce stock (creates PRODUCT_STOCK_REDUCED topic)
echo.
echo   Category Service:
echo     11. Create category (creates CATEGORY_CREATED topic)
echo.
echo   Order/Payment Service:
echo     12. Process payment (creates PAYMENT_SUCCESS topic)
echo     13. Create order (creates ORDER_PLACED topic)
echo     14. Update order status (creates ORDER_STATUS_UPDATED topic)
echo.
echo   Inventory:
echo     15. Low stock alert (creates LOW_STOCK_ALERT topic)
echo.
echo To monitor topics in real-time:
echo   docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning
echo.
pause
