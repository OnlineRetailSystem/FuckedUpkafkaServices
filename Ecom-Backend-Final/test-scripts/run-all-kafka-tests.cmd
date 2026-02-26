@echo off
REM ============================================================
REM Master Kafka Test Runner
REM Runs all Kafka-related tests in sequence
REM ============================================================

echo ================================================================
echo          MASTER KAFKA TEST SUITE
echo ================================================================
echo.
echo This will run all Kafka tests in the following order:
echo.
echo 1. Kafka Topics Verification (checks all 15 topics)
echo 2. Existing Services Test (Auth, Order, Payment)
echo 3. New Services Test (Cart, Product, Category)
echo.
echo Total estimated time: 10-15 minutes
echo.
pause

set TESTS_PASSED=0
set TESTS_FAILED=0

echo ================================================================
echo TEST SUITE 1: Kafka Infrastructure
echo ================================================================
echo.

echo Running: test-kafka-topics.cmd
echo.
call test-kafka-topics.cmd
if errorlevel 1 (
    echo FAILED: Kafka topics verification
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: Kafka topics verification
    set /a TESTS_PASSED+=1
)

echo.
echo Press any key to continue to next test suite...
pause >nul

echo ================================================================
echo TEST SUITE 2: Existing Kafka Flows
echo ================================================================
echo.

echo Running: test-kafka-flow.cmd
echo.
call test-kafka-flow.cmd
if errorlevel 1 (
    echo FAILED: Existing Kafka flows
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: Existing Kafka flows
    set /a TESTS_PASSED+=1
)

echo.
echo Press any key to continue to next test suite...
pause >nul

echo ================================================================
echo TEST SUITE 3: Category Service Kafka Flow
echo ================================================================
echo.

echo Running: test-category-kafka-flow.cmd
echo.
call test-category-kafka-flow.cmd
if errorlevel 1 (
    echo FAILED: Category service Kafka flow
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: Category service Kafka flow
    set /a TESTS_PASSED+=1
)

echo.
echo Press any key to continue to next test suite...
pause >nul

echo ================================================================
echo TEST SUITE 4: Product Service Kafka Flow
echo ================================================================
echo.

echo Running: test-product-kafka-flow.cmd
echo.
call test-product-kafka-flow.cmd
if errorlevel 1 (
    echo FAILED: Product service Kafka flow
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: Product service Kafka flow
    set /a TESTS_PASSED+=1
)

echo.
echo Press any key to continue to next test suite...
pause >nul

echo ================================================================
echo TEST SUITE 5: Cart Service Kafka Flow
echo ================================================================
echo.

echo Running: test-cart-kafka-flow.cmd
echo.
call test-cart-kafka-flow.cmd
if errorlevel 1 (
    echo FAILED: Cart service Kafka flow
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: Cart service Kafka flow
    set /a TESTS_PASSED+=1
)

echo.
echo Press any key to continue to final verification...
pause >nul

echo ================================================================
echo FINAL VERIFICATION: All New Services Together
echo ================================================================
echo.

echo Running: test-all-new-kafka-flows.cmd
echo.
call test-all-new-kafka-flows.cmd
if errorlevel 1 (
    echo FAILED: All new services integration
    set /a TESTS_FAILED+=1
) else (
    echo PASSED: All new services integration
    set /a TESTS_PASSED+=1
)

echo.
echo.

echo ================================================================
echo                    FINAL TEST REPORT
echo ================================================================
echo.

set /a TOTAL_TESTS=%TESTS_PASSED%+%TESTS_FAILED%

echo Total Test Suites: %TOTAL_TESTS%
echo Passed: %TESTS_PASSED%
echo Failed: %TESTS_FAILED%
echo.

if %TESTS_FAILED% EQU 0 (
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║                    ALL TESTS PASSED! ✓                      ║
    echo ╚══════════════════════════════════════════════════════════════╝
) else (
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║                  SOME TESTS FAILED! ✗                       ║
    echo ╚══════════════════════════════════════════════════════════════╝
)

echo.

echo ================================================================
echo                    KAFKA TOPICS SUMMARY
echo ================================================================
echo.

echo Listing all Kafka topics:
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092

echo.

echo ================================================================
echo                    PROCESSED EVENTS SUMMARY
echo ================================================================
echo.

echo Counting processed events by type:
docker exec ecom-mysql mysql -uroot -proot -e "SELECT eventType, COUNT(*) as count FROM notificationdb.processed_events GROUP BY eventType;" 2>nul

echo.

echo ================================================================
echo                    CONSUMER GROUP STATUS
echo ================================================================
echo.

echo Checking notification-service-group:
docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092

echo.

echo ================================================================
echo                    DETAILED BREAKDOWN
echo ================================================================
echo.

echo Existing Kafka Topics (6):
echo   - USER_REGISTERED
echo   - USER_LOGGED_IN
echo   - PAYMENT_SUCCESS
echo   - ORDER_PLACED
echo   - ORDER_STATUS_UPDATED
echo   - LOW_STOCK_ALERT
echo.

echo New Kafka Topics (9):
echo.
echo   Cart Service (4):
echo     - ITEM_ADDED_TO_CART
echo     - ITEM_REMOVED_FROM_CART
echo     - CART_UPDATED
echo     - CART_CLEARED
echo.
echo   Product Service (4):
echo     - PRODUCT_CREATED
echo     - PRODUCT_UPDATED
echo     - PRODUCT_DELETED
echo     - PRODUCT_STOCK_REDUCED
echo.
echo   Category Service (1):
echo     - CATEGORY_CREATED
echo.

echo Total Kafka Topics: 15
echo.

echo ================================================================
echo                    RECOMMENDATIONS
echo ================================================================
echo.

if %TESTS_FAILED% GTR 0 (
    echo Review failed test logs above
    echo Check service logs: docker logs [service-name]
    echo Verify Kafka connectivity
    echo Check application.properties for Kafka configuration
) else (
    echo All Kafka flows are working correctly!
    echo System is ready for production use
    echo Consider running load tests next
)

echo.

echo ================================================================
echo                    NEXT STEPS
echo ================================================================
echo.

echo 1. Review all monitoring windows that were opened
echo 2. Check notification service logs for all event types
echo 3. Verify idempotency (no duplicate processing)
echo 4. Test with frontend application
echo 5. Run performance/load tests
echo 6. Monitor consumer lag under load
echo.

echo ================================================================
echo                    USEFUL COMMANDS
echo ================================================================
echo.

echo Monitor all Kafka topics:
echo   docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092
echo.

echo Check consumer group lag:
echo   docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092
echo.

echo View processed events:
echo   curl http://localhost:8089/notifications/processed-events
echo.

echo Check service logs:
echo   docker logs ecom-cartservice -f
echo   docker logs ecom-productservice -f
echo   docker logs ecom-categoryservice -f
echo   docker logs ecom-notificationservice -f
echo.

echo ================================================================
echo                    TEST SUITE COMPLETE
echo ================================================================
echo.

echo All Kafka tests have been executed!
echo.
echo Test Results: %TESTS_PASSED%/%TOTAL_TESTS% passed
echo.

if %TESTS_FAILED% EQU 0 (
    echo Status: SUCCESS ✓
    exit /b 0
) else (
    echo Status: FAILED ✗
    exit /b 1
)

pause
