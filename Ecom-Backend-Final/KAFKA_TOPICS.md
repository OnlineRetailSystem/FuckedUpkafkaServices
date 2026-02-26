# Kafka Topics Documentation

## Overview
This document lists all Kafka topics implemented across the microservices architecture.

## Existing Topics (Already Implemented)

### Auth Service
- **USER_REGISTERED** - Published when a new user registers
- **USER_LOGGED_IN** - Published when a user logs in

### Order Service
- **ORDER_PLACED** - Published when an order is placed
- **ORDER_STATUS_UPDATED** - Published when order shipping status changes
- **PAYMENT_SUCCESS** - Published when payment is successful

### Product Service (Inventory)
- **LOW_STOCK_ALERT** - Published when product stock falls below threshold

## New Topics Added

### Cart Service (Producer)
- **ITEM_ADDED_TO_CART** - Published when user adds item to cart
- **ITEM_REMOVED_FROM_CART** - Published when user removes item from cart
- **CART_UPDATED** - Published when cart item quantity is updated
- **CART_CLEARED** - Published when user clears entire cart

### Product Service (Producer)
- **PRODUCT_CREATED** - Published when new product is added
- **PRODUCT_UPDATED** - Published when product details are modified
- **PRODUCT_DELETED** - Published when product is removed
- **PRODUCT_STOCK_REDUCED** - Published when product stock is reduced

### Category Service (Producer)
- **CATEGORY_CREATED** - Published when new category is added

## Consumer

### Notification Service
Consumes ALL topics listed above and logs appropriate notifications for:
- User events (registration, login)
- Cart events (add, remove, update, clear)
- Product events (create, update, delete, stock reduction)
- Category events (creation)
- Order events (placement, status updates)
- Payment events (success)
- Inventory alerts (low stock)

## Event Structure

### Cart Events
```json
{
  "eventId": "uuid",
  "eventType": "ITEM_ADDED_TO_CART | ITEM_REMOVED_FROM_CART | CART_UPDATED | CART_CLEARED",
  "username": "string",
  "productId": "long",
  "productName": "string",
  "quantity": "integer",
  "price": "double",
  "timestamp": "LocalDateTime"
}
```

### Product Events
```json
{
  "eventId": "uuid",
  "eventType": "PRODUCT_CREATED | PRODUCT_UPDATED | PRODUCT_DELETED | PRODUCT_STOCK_REDUCED",
  "productId": "long",
  "productName": "string",
  "category": "string",
  "price": "double",
  "quantity": "integer",
  "timestamp": "LocalDateTime"
}
```

### Category Events
```json
{
  "eventId": "uuid",
  "eventType": "CATEGORY_CREATED",
  "categoryId": "long",
  "categoryName": "string",
  "timestamp": "LocalDateTime"
}
```

## Configuration

All services are configured to connect to Kafka at:
```
spring.kafka.bootstrap-servers=kafka:9092
```

## Idempotency

The notification service implements idempotency using:
- Event ID tracking in database
- Duplicate detection before processing
- Processed events are stored to prevent reprocessing
