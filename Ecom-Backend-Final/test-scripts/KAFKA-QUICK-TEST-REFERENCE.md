# Kafka Quick Test Reference

## Quick Start

### Run All Tests
```cmd
cd test-scripts
run-all-kafka-tests.cmd
```

### Run Individual Tests

#### Test Kafka Topics
```cmd
test-kafka-topics.cmd
```
Verifies all 15 Kafka topics are accessible.

#### Test Cart Service
```cmd
test-cart-kafka-flow.cmd
```
Tests: ITEM_ADDED_TO_CART, CART_UPDATED, ITEM_REMOVED_FROM_CART, CART_CLEARED

#### Test Product Service
```cmd
test-product-kafka-flow.cmd
```
Tests: PRODUCT_CREATED, PRODUCT_UPDATED, PRODUCT_DELETED, PRODUCT_STOCK_REDUCED

#### Test Category Service
```cmd
test-category-kafka-flow.cmd
```
Tests: CATEGORY_CREATED

#### Test All New Services
```cmd
test-all-new-kafka-flows.cmd
```
Comprehensive test of all 9 new Kafka events.

## Quick Verification Commands

### Check Kafka is Running
```cmd
docker ps | findstr kafka
```

### List All Topics
```cmd
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Check Specific Topic
```cmd
docker exec ecom-kafka kafka-topics --describe --topic ITEM_ADDED_TO_CART --bootstrap-server localhost:9092
```

### Monitor Topic Messages
```cmd
docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning
```

### Check Consumer Group
```cmd
docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092
```

### Check Processed Events
```cmd
curl http://localhost:8089/notifications/processed-events
```

### Count Events by Type
```cmd
docker exec ecom-mysql mysql -uroot -proot -e "SELECT eventType, COUNT(*) as count FROM notificationdb.processed_events GROUP BY eventType;"
```

## Quick Service Log Checks

### Cart Service
```cmd
docker logs ecom-cartservice --tail 20 | findstr "Publishing"
```

### Product Service
```cmd
docker logs ecom-productservice --tail 20 | findstr "Publishing"
```

### Category Service
```cmd
docker logs ecom-categoryservice --tail 20 | findstr "Publishing"
```

### Notification Service
```cmd
docker logs ecom-notificationservice --tail 50 | findstr "NOTIFICATION"
```

## Quick API Tests

### Cart Service
```cmd
REM Add to cart
curl -X POST "http://localhost:8090/cart/add" -H "Content-Type: application/json" -d "{\"username\": \"testuser\", \"productId\": 1, \"quantity\": 2}"

REM View cart
curl http://localhost:8090/cart/testuser

REM Clear cart
curl -X DELETE http://localhost:8090/cart/clear/testuser
```

### Product Service
```cmd
REM Create product
curl -X POST "http://localhost:8090/products" -H "Content-Type: application/json" -d "{\"name\": \"Test\", \"price\": 99.99, \"quantity\": 50, \"category\": \"Electronics\"}"

REM Update product
curl -X PUT "http://localhost:8090/products/1" -H "Content-Type: application/json" -d "{\"price\": 149.99}"

REM Delete product
curl -X DELETE http://localhost:8090/products/1
```

### Category Service
```cmd
REM Create category
curl -X POST "http://localhost:8090/categories" -H "Content-Type: application/json" -d "{\"name\": \"Electronics\"}"

REM List categories
curl http://localhost:8090/categories
```

## Troubleshooting Quick Fixes

### Topics Not Created
```cmd
REM Topics auto-create on first event. Trigger an action:
curl -X POST "http://localhost:8090/categories" -H "Content-Type: application/json" -d "{\"name\": \"Test\"}"
```

### Consumer Not Active
```cmd
REM Restart notification service
docker restart ecom-notificationservice

REM Check logs
docker logs ecom-notificationservice -f
```

### Kafka Connection Issues
```cmd
REM Check Kafka logs
docker logs ecom-kafka --tail 50

REM Restart Kafka
docker restart ecom-kafka
```

### Clear Test Data
```cmd
REM Clear processed events
docker exec ecom-mysql mysql -uroot -proot -e "TRUNCATE TABLE notificationdb.processed_events;"

REM Delete Kafka topics (if needed)
docker exec ecom-kafka kafka-topics --delete --topic ITEM_ADDED_TO_CART --bootstrap-server localhost:9092
```

## Expected Event Counts

After running complete test suite:

| Event Type | Expected Count |
|------------|----------------|
| USER_REGISTERED | 1+ |
| USER_LOGGED_IN | 1+ |
| CATEGORY_CREATED | 1+ |
| PRODUCT_CREATED | 1+ |
| PRODUCT_UPDATED | 1+ |
| PRODUCT_DELETED | 1+ |
| PRODUCT_STOCK_REDUCED | 1+ |
| ITEM_ADDED_TO_CART | 2+ |
| CART_UPDATED | 1+ |
| ITEM_REMOVED_FROM_CART | 1+ |
| CART_CLEARED | 1+ |
| ORDER_PLACED | 0+ |
| PAYMENT_SUCCESS | 0+ |
| ORDER_STATUS_UPDATED | 0+ |
| LOW_STOCK_ALERT | 0+ |

## Performance Benchmarks

### Normal Operation
- Event publish time: < 100ms
- Event consumption time: < 200ms
- End-to-end latency: < 500ms
- Consumer lag: 0

### Under Load (100 events/sec)
- Consumer lag: < 10 messages
- Processing time: < 1 second
- No message loss

## Success Indicators

✅ All 15 topics exist in Kafka
✅ All services show "Publishing" in logs
✅ Notification service shows formatted notifications
✅ Processed events table has entries
✅ Consumer group shows LAG = 0
✅ No errors in service logs
✅ Idempotency working (no duplicates)

## Common Issues

### Issue: "Connection refused"
**Fix:** Check service is running and Kafka is accessible

### Issue: "Topic not found"
**Fix:** Topic will auto-create on first event

### Issue: "Duplicate events"
**Fix:** Check idempotency logic in NotificationEventConsumer

### Issue: "Consumer lag increasing"
**Fix:** Check notification service performance, may need scaling

## Monitoring Dashboard Commands

### Open All Monitoring Windows
```cmd
start cmd /k "docker logs ecom-cartservice -f"
start cmd /k "docker logs ecom-productservice -f"
start cmd /k "docker logs ecom-categoryservice -f"
start cmd /k "docker logs ecom-notificationservice -f"
```

### Monitor All New Topics
```cmd
start cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning"
start cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic PRODUCT_CREATED --from-beginning"
start cmd /k "docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic CATEGORY_CREATED --from-beginning"
```

## Documentation Links

- [Complete Test Guide](NEW-KAFKA-FLOWS-TEST-GUIDE.md)
- [Kafka Topics Documentation](../KAFKA_TOPICS.md)
- [Architecture Documentation](../ARCHITECTURE.md)

## Support Checklist

Before asking for help:
- [ ] Checked all services are running
- [ ] Verified Kafka is accessible
- [ ] Reviewed service logs for errors
- [ ] Checked consumer group status
- [ ] Verified application.properties configuration
- [ ] Tested with curl commands
- [ ] Checked processed events table
