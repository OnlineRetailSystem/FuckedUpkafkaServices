package com.ecom.productservice.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.ecom.productservice.events.ProductEvent;

@Service
public class ProductEventProducer {

    private static final Logger log = LoggerFactory.getLogger(ProductEventProducer.class);

    private static final String TOPIC_PRODUCT_CREATED = "PRODUCT_CREATED";
    private static final String TOPIC_PRODUCT_UPDATED = "PRODUCT_UPDATED";
    private static final String TOPIC_PRODUCT_DELETED = "PRODUCT_DELETED";
    private static final String TOPIC_PRODUCT_STOCK_REDUCED = "PRODUCT_STOCK_REDUCED";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public ProductEventProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishProductCreated(Long productId, String productName, String category, Double price, Integer quantity) {
        ProductEvent event = new ProductEvent("PRODUCT_CREATED", productId, productName, category, price, quantity);
        log.info("Publishing PRODUCT_CREATED event: {}", event);
        kafkaTemplate.send(TOPIC_PRODUCT_CREATED, event.getEventId(), event);
    }

    public void publishProductUpdated(Long productId, String productName, String category, Double price, Integer quantity) {
        ProductEvent event = new ProductEvent("PRODUCT_UPDATED", productId, productName, category, price, quantity);
        log.info("Publishing PRODUCT_UPDATED event: {}", event);
        kafkaTemplate.send(TOPIC_PRODUCT_UPDATED, event.getEventId(), event);
    }

    public void publishProductDeleted(Long productId, String productName, String category) {
        ProductEvent event = new ProductEvent("PRODUCT_DELETED", productId, productName, category, null, null);
        log.info("Publishing PRODUCT_DELETED event: {}", event);
        kafkaTemplate.send(TOPIC_PRODUCT_DELETED, event.getEventId(), event);
    }

    public void publishProductStockReduced(Long productId, String productName, String category, Integer newQuantity) {
        ProductEvent event = new ProductEvent("PRODUCT_STOCK_REDUCED", productId, productName, category, null, newQuantity);
        log.info("Publishing PRODUCT_STOCK_REDUCED event: {}", event);
        kafkaTemplate.send(TOPIC_PRODUCT_STOCK_REDUCED, event.getEventId(), event);
    }
}
