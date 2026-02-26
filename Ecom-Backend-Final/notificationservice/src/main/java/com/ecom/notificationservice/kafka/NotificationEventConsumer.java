package com.ecom.notificationservice.kafka;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.ecom.notificationservice.model.ProcessedEvent;
import com.ecom.notificationservice.repository.ProcessedEventRepository;

@Service
public class NotificationEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(NotificationEventConsumer.class);

    private final ProcessedEventRepository processedEventRepository;

    public NotificationEventConsumer(ProcessedEventRepository processedEventRepository) {
        this.processedEventRepository = processedEventRepository;
    }

    // ========================
    // USER_REGISTERED
    // ========================
    @KafkaListener(topics = "USER_REGISTERED", groupId = "notification-service-group")
    public void consumeUserRegistered(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "USER_REGISTERED"))
            return;

        String username = (String) eventData.get("username");
        String email = (String) eventData.get("email");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  📧 NOTIFICATION: Welcome Email                            ║");
        log.info("║  To: {} ({})                                       ", username, email);
        log.info("║  Subject: Welcome to Ecom!                                 ║");
        log.info("║  Body: Thank you for registering, {}!              ", username);
        log.info("║  Your account has been created successfully.               ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "USER_REGISTERED");
    }

    // ========================
    // USER_LOGGED_IN
    // ========================
    @KafkaListener(topics = "USER_LOGGED_IN", groupId = "notification-service-group")
    public void consumeUserLoggedIn(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "USER_LOGGED_IN"))
            return;

        String username = (String) eventData.get("username");
        String roles = (String) eventData.get("roles");
        
        // Check if user is admin
        boolean isAdmin = roles != null && roles.toUpperCase().contains("ADMIN");

        if (isAdmin) {
            log.info("╔══════════════════════════════════════════════════════════════╗");
            log.info("║  👑 ADMIN NOTIFICATION: Admin Login                        ║");
            log.info("║  Admin: {} has logged in                           ", username);
            log.info("║  Roles: {}                                         ", roles);
            log.info("║  Time: {}                                          ", eventData.get("timestamp"));
            log.info("╚══════════════════════════════════════════════════════════════╝");
        } else {
            log.info("╔══════════════════════════════════════════════════════════════╗");
            log.info("║  🔑 NOTIFICATION: User Login                               ║");
            log.info("║  User: {} has logged in                            ", username);
            log.info("║  Time: {}                                          ", eventData.get("timestamp"));
            log.info("╚══════════════════════════════════════════════════════════════╝");
        }

        markProcessed(eventId, "USER_LOGGED_IN");
    }

    // ========================
    // LOW_STOCK_ALERT
    // ========================
    @KafkaListener(topics = "LOW_STOCK_ALERT", groupId = "notification-service-group")
    public void consumeLowStockAlert(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "LOW_STOCK_ALERT"))
            return;

        String productName = (String) eventData.get("productName");
        Object productId = eventData.get("productId");
        Object currentStock = eventData.get("currentStock");
        Object threshold = eventData.get("threshold");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🚨 ADMIN NOTIFICATION: Low Stock Alert                    ║");
        log.info("║  Product: {} (ID: {})                              ", productName, productId);
        log.info("║  Current Stock: {}                                 ", currentStock);
        log.info("║  Threshold: {}                                     ", threshold);
        log.info("║  Action Required: Please restock immediately!              ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "LOW_STOCK_ALERT");
    }

    // ========================
    // ORDER_STATUS_UPDATED
    // ========================
    @KafkaListener(topics = "ORDER_STATUS_UPDATED", groupId = "notification-service-group")
    public void consumeOrderStatusUpdated(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "ORDER_STATUS_UPDATED"))
            return;

        String username = (String) eventData.get("username");
        Object orderId = eventData.get("orderId");
        String shippingStatus = (String) eventData.get("shippingStatus");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  📦 NOTIFICATION: Order Status Update                      ║");
        log.info("║  To: {}                                            ", username);
        log.info("║  Order: #{}                                        ", orderId);
        log.info("║  Shipping Status: {}                               ", shippingStatus);
        log.info("║  Your order shipping status has been updated.              ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "ORDER_STATUS_UPDATED");
    }

    // ========================
    // CART EVENTS
    // ========================
    @KafkaListener(topics = "ITEM_ADDED_TO_CART", groupId = "notification-service-group")
    public void consumeItemAddedToCart(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "ITEM_ADDED_TO_CART"))
            return;

        String username = (String) eventData.get("username");
        String productName = (String) eventData.get("productName");
        Object quantity = eventData.get("quantity");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🛒 NOTIFICATION: Item Added to Cart                       ║");
        log.info("║  User: {}                                          ", username);
        log.info("║  Product: {}                                       ", productName);
        log.info("║  Quantity: {}                                      ", quantity);
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "ITEM_ADDED_TO_CART");
    }

    @KafkaListener(topics = "ITEM_REMOVED_FROM_CART", groupId = "notification-service-group")
    public void consumeItemRemovedFromCart(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "ITEM_REMOVED_FROM_CART"))
            return;

        String username = (String) eventData.get("username");
        String productName = (String) eventData.get("productName");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🗑️ NOTIFICATION: Item Removed from Cart                   ║");
        log.info("║  User: {}                                          ", username);
        log.info("║  Product: {}                                       ", productName);
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "ITEM_REMOVED_FROM_CART");
    }

    @KafkaListener(topics = "CART_UPDATED", groupId = "notification-service-group")
    public void consumeCartUpdated(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "CART_UPDATED"))
            return;

        String username = (String) eventData.get("username");
        String productName = (String) eventData.get("productName");
        Object quantity = eventData.get("quantity");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🔄 NOTIFICATION: Cart Updated                             ║");
        log.info("║  User: {}                                          ", username);
        log.info("║  Product: {}                                       ", productName);
        log.info("║  New Quantity: {}                                  ", quantity);
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "CART_UPDATED");
    }

    @KafkaListener(topics = "CART_CLEARED", groupId = "notification-service-group")
    public void consumeCartCleared(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "CART_CLEARED"))
            return;

        String username = (String) eventData.get("username");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🧹 NOTIFICATION: Cart Cleared                             ║");
        log.info("║  User: {}                                          ", username);
        log.info("║  Your cart has been cleared.                               ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "CART_CLEARED");
    }

    // ========================
    // PRODUCT EVENTS
    // ========================
    @KafkaListener(topics = "PRODUCT_CREATED", groupId = "notification-service-group")
    public void consumeProductCreated(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "PRODUCT_CREATED"))
            return;

        String productName = (String) eventData.get("productName");
        String category = (String) eventData.get("category");
        Object price = eventData.get("price");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  ✨ ADMIN NOTIFICATION: New Product Created                ║");
        log.info("║  Product: {}                                       ", productName);
        log.info("║  Category: {}                                      ", category);
        log.info("║  Price: ${}                                        ", price);
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "PRODUCT_CREATED");
    }

    @KafkaListener(topics = "PRODUCT_UPDATED", groupId = "notification-service-group")
    public void consumeProductUpdated(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "PRODUCT_UPDATED"))
            return;

        String productName = (String) eventData.get("productName");
        Object productId = eventData.get("productId");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🔧 ADMIN NOTIFICATION: Product Updated                    ║");
        log.info("║  Product: {} (ID: {})                              ", productName, productId);
        log.info("║  Product details have been updated.                        ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "PRODUCT_UPDATED");
    }

    @KafkaListener(topics = "PRODUCT_DELETED", groupId = "notification-service-group")
    public void consumeProductDeleted(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "PRODUCT_DELETED"))
            return;

        String productName = (String) eventData.get("productName");
        Object productId = eventData.get("productId");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  🗑️ ADMIN NOTIFICATION: Product Deleted                    ║");
        log.info("║  Product: {} (ID: {})                              ", productName, productId);
        log.info("║  Product has been removed from catalog.                    ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "PRODUCT_DELETED");
    }

    @KafkaListener(topics = "PRODUCT_STOCK_REDUCED", groupId = "notification-service-group")
    public void consumeProductStockReduced(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "PRODUCT_STOCK_REDUCED"))
            return;

        String productName = (String) eventData.get("productName");
        Object productId = eventData.get("productId");
        Object quantity = eventData.get("quantity");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  📉 NOTIFICATION: Product Stock Reduced                    ║");
        log.info("║  Product: {} (ID: {})                              ", productName, productId);
        log.info("║  Remaining Stock: {}                               ", quantity);
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "PRODUCT_STOCK_REDUCED");
    }

    // ========================
    // CATEGORY EVENTS
    // ========================
    @KafkaListener(topics = "CATEGORY_CREATED", groupId = "notification-service-group")
    public void consumeCategoryCreated(Map<String, Object> eventData) {
        String eventId = (String) eventData.get("eventId");
        if (isDuplicate(eventId, "CATEGORY_CREATED"))
            return;

        String categoryName = (String) eventData.get("categoryName");
        Object categoryId = eventData.get("categoryId");

        log.info("╔══════════════════════════════════════════════════════════════╗");
        log.info("║  📁 ADMIN NOTIFICATION: New Category Created               ║");
        log.info("║  Category: {} (ID: {})                             ", categoryName, categoryId);
        log.info("║  New category is now available in the catalog.             ║");
        log.info("╚══════════════════════════════════════════════════════════════╝");

        markProcessed(eventId, "CATEGORY_CREATED");
    }

    // ========================
    // Idempotency Helpers
    // ========================
    private boolean isDuplicate(String eventId, String eventType) {
        if (eventId == null) {
            log.warn("Event with null eventId received for type: {}. Processing anyway.", eventType);
            return false;
        }
        if (processedEventRepository.existsByEventId(eventId)) {
            log.warn("Duplicate event detected: eventId={}, type={}. Skipping.", eventId, eventType);
            return true;
        }
        return false;
    }

    private void markProcessed(String eventId, String eventType) {
        if (eventId != null) {
            processedEventRepository.save(new ProcessedEvent(eventId, eventType));
        }
    }
}
