# New Kafka Flows Test Guide

## Overview
This guide covers testing the newly implemented Kafka event flows for Cart, Product, and Category services.

## New Kafka Topics

### Cart Service (4 topics)
1. **ITEM_ADDED_TO_CART** - Triggered when user adds item to cart
2. **ITEM_REMOVED_FROM_CART** - Triggered when user removes item from cart
3. **CART_UPDATED** - Triggered when cart item quantity is updated
4. **CART_CLEARED** - Triggered when user clears entire cart

### Product Service (4 topics)
1. **PRODUCT_CREATED** - Triggered when admin creates new product
2. **PRODUCT_UPDATED** - Triggered when admin updates product details
3. **PRODUCT_DELETED** - Triggered when admin deletes product
4. **PRODUCT_STOCK_REDUCED** - Triggered when product stock is reduced

### Category Service (1 topic)
1. **CATEGORY_CREATED** - Triggered when admin creates new category

## Test Scripts

### Individual Service Tests

#### 1. Cart Service Test
```cmd
test-cart-kafka-flow.cmd
```
Tests all 4 cart-related Kafka events:
- Add item to cart
- Update cart item
- Remove item from cart
- Clear cart

#### 2. Product Service Test
```cmd
test-product-kafka-flow.cmd
```
Tests all 4 product-related Kafka events:
- Create product
- Update product
- Reduce stock
- Delete product

#### 3. Category Service Test
```cmd
test-category-kafka-flow.cmd
```
Tests category creation Kafka event:
- Create category

### Comprehensive Test

#### All New Services Test
```cmd
test-all-new-kafka-flows.cmd
```
Comprehensive test that:
- Tests all 9 new Kafka event types
- Opens monitoring windows for all services
- Opens Kafka topic monitors
- Verifies event processing
- Checks idempotency

### Updated Existing Tests

#### Kafka Topics Verification
```cmd
test-kafka-topics.cmd
```
Updated to check for all 15 Kafka topics (6 existing + 9 new)

## Test Execution Steps

### Prerequisites
1. All services must be running:
   ```cmd
   docker-compose up -d
   ```

2. Verify services are healthy:
   ```cmd
   docker ps
   ```

3. Check Kafka is running:
   ```cmd
   docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092
   ```

### Running Tests

#### Quick Test (Individual Services)
```cmd
cd test-scripts

REM Test cart service
test-cart-kafka-flow.cmd

REM Test product service
test-product-kafka-flow.cmd

REM Test category service
test-category-kafka-flow.cmd
```

#### Comprehensive Test (All New Services)
```cmd
cd test-scripts
test-all-new-kafka-flows.cmd
```

This will:
1. Check all services are running
2. Open monitoring windows for logs
3. Execute test scenarios for all services
4. Open Kafka topic monitors
5. Verify event processing
6. Display summary and verification checklist

## Manual Verification

### 1. Check Service Logs

#### Cart Service
```cmd
docker logs ecom-cartservice --tail 50
```
Look for: "Publishing ITEM_ADDED_TO_CART event"

#### Product Service
```cmd
docker logs ecom-productservice --tail 50
```
Look for: "Publishing PRODUCT_CREATED event"

#### Category Service
```cmd
docker logs ecom-categoryservice --tail 50
```
Look for: "Publishing CATEGORY_CREATED event"

#### Notification Service
```cmd
docker logs ecom-notificationservice --tail 50
```
Look for: Formatted notification boxes for each event type

### 2. Check Kafka Topics

#### List all topics
```cmd
docker exec ecom-kafka kafka-topics --list --bootstrap-server localhost:9092
```

#### Check specific topic
```cmd
docker exec ecom-kafka kafka-topics --describe --topic ITEM_ADDED_TO_CART --bootstrap-server localhost:9092
```

#### Monitor topic messages
```cmd
docker exec ecom-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ITEM_ADDED_TO_CART --from-beginning
```

### 3. Check Processed Events

#### Via API
```cmd
curl http://localhost:8089/notifications/processed-events
```

#### Via Database
```cmd
docker exec ecom-mysql mysql -uroot -proot -e "SELECT * FROM notificationdb.processed_events ORDER BY id DESC LIMIT 20;"
```

#### Count by Event Type
```cmd
docker exec ecom-mysql mysql -uroot -proot -e "SELECT eventType, COUNT(*) as count FROM notificationdb.processed_events GROUP BY eventType;"
```

### 4. Check Consumer Group

```cmd
docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092
```

Look for:
- Consumer is active
- No lag in consumption
- All topics are being consumed

## Expected Results

### Cart Service Events

#### ITEM_ADDED_TO_CART
```
╔══════════════════════════════════════════════════════════════╗
║  🛒 NOTIFICATION: Item Added to Cart                       ║
║  User: testuser                                            ║
║  Product: Test Product                                     ║
║  Quantity: 2                                               ║
╚══════════════════════════════════════════════════════════════╝
```

#### CART_UPDATED
```
╔══════════════════════════════════════════════════════════════╗
║  🔄 NOTIFICATION: Cart Updated                             ║
║  User: testuser                                            ║
║  Product: Test Product                                     ║
║  New Quantity: 5                                           ║
╚══════════════════════════════════════════════════════════════╝
```

#### ITEM_REMOVED_FROM_CART
```
╔══════════════════════════════════════════════════════════════╗
║  🗑️ NOTIFICATION: Item Removed from Cart                   ║
║  User: testuser                                            ║
║  Product: Test Product                                     ║
╚══════════════════════════════════════════════════════════════╝
```

#### CART_CLEARED
```
╔══════════════════════════════════════════════════════════════╗
║  🧹 NOTIFICATION: Cart Cleared                             ║
║  User: testuser                                            ║
║  Your cart has been cleared.                               ║
╚══════════════════════════════════════════════════════════════╝
```

### Product Service Events

#### PRODUCT_CREATED
```
╔══════════════════════════════════════════════════════════════╗
║  ✨ ADMIN NOTIFICATION: New Product Created                ║
║  Product: Test Product                                     ║
║  Category: Electronics                                     ║
║  Price: $99.99                                             ║
╚══════════════════════════════════════════════════════════════╝
```

#### PRODUCT_UPDATED
```
╔══════════════════════════════════════════════════════════════╗
║  🔧 ADMIN NOTIFICATION: Product Updated                    ║
║  Product: Test Product (ID: 1)                             ║
║  Product details have been updated.                        ║
╚══════════════════════════════════════════════════════════════╝
```

#### PRODUCT_DELETED
```
╔══════════════════════════════════════════════════════════════╗
║  🗑️ ADMIN NOTIFICATION: Product Deleted                    ║
║  Product: Test Product (ID: 1)                             ║
║  Product has been removed from catalog.                    ║
╚══════════════════════════════════════════════════════════════╝
```

#### PRODUCT_STOCK_REDUCED
```
╔══════════════════════════════════════════════════════════════╗
║  📉 NOTIFICATION: Product Stock Reduced                    ║
║  Product: Test Product (ID: 1)                             ║
║  Remaining Stock: 40                                       ║
╚══════════════════════════════════════════════════════════════╝
```

### Category Service Events

#### CATEGORY_CREATED
```
╔══════════════════════════════════════════════════════════════╗
║  📁 ADMIN NOTIFICATION: New Category Created               ║
║  Category: Electronics (ID: 1)                             ║
║  New category is now available in the catalog.             ║
╚══════════════════════════════════════════════════════════════╝
```

## Troubleshooting

### Issue: Topics not created
**Solution:** Topics are auto-created on first event. Trigger the corresponding action.

### Issue: Events not consumed
**Solution:** 
1. Check notification service is running
2. Check Kafka connection in application.properties
3. Verify consumer group is active

### Issue: Duplicate events processed
**Solution:** Check idempotency implementation in NotificationEventConsumer

### Issue: Service not publishing events
**Solution:**
1. Check service logs for errors
2. Verify Kafka producer configuration
3. Check Kafka is accessible from service

## Performance Testing

### Load Test - Cart Service
```cmd
REM Add 100 items to cart rapidly
for /L %%i in (1,1,100) do (
    curl -X POST "http://localhost:8090/cart/add" -H "Content-Type: application/json" -d "{\"username\": \"loadtest\", \"productId\": 1, \"quantity\": 1}"
)
```

### Load Test - Product Service
```cmd
REM Create 50 products rapidly
for /L %%i in (1,1,50) do (
    curl -X POST "http://localhost:8090/products" -H "Content-Type: application/json" -d "{\"name\": \"Product%%i\", \"price\": 99.99, \"quantity\": 100, \"category\": \"Test\"}"
)
```

### Check Consumer Lag
```cmd
docker exec ecom-kafka kafka-consumer-groups --describe --group notification-service-group --bootstrap-server localhost:9092
```

## Success Criteria

✅ All 9 new Kafka topics are created
✅ All events are published by producer services
✅ All events are consumed by notification service
✅ All events are logged with proper formatting
✅ All events are stored in processed_events table
✅ No duplicate processing occurs
✅ Consumer group shows no lag
✅ All services show proper Kafka connectivity

## Additional Resources

- [Kafka Topics Documentation](../KAFKA_TOPICS.md)
- [Architecture Documentation](../ARCHITECTURE.md)
- [Complete Kafka Flow Test](test-complete-kafka-flow.cmd)
- [Kafka Topics Verification](test-kafka-topics.cmd)

## Support

For issues or questions:
1. Check service logs
2. Verify Kafka connectivity
3. Review event structure in KAFKA_TOPICS.md
4. Check consumer group status
