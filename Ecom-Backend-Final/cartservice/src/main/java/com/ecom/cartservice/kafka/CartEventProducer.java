package com.ecom.cartservice.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.ecom.cartservice.events.CartEvent;

@Service
public class CartEventProducer {

    private static final Logger log = LoggerFactory.getLogger(CartEventProducer.class);

    private static final String TOPIC_ITEM_ADDED_TO_CART = "ITEM_ADDED_TO_CART";
    private static final String TOPIC_ITEM_REMOVED_FROM_CART = "ITEM_REMOVED_FROM_CART";
    private static final String TOPIC_CART_UPDATED = "CART_UPDATED";
    private static final String TOPIC_CART_CLEARED = "CART_CLEARED";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CartEventProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishItemAddedToCart(String username, Long productId, String productName, Integer quantity, Double price) {
        CartEvent event = new CartEvent("ITEM_ADDED_TO_CART", username, productId, productName, quantity, price);
        log.info("Publishing ITEM_ADDED_TO_CART event: {}", event);
        kafkaTemplate.send(TOPIC_ITEM_ADDED_TO_CART, event.getEventId(), event);
    }

    public void publishItemRemovedFromCart(String username, Long productId, String productName, Integer quantity, Double price) {
        CartEvent event = new CartEvent("ITEM_REMOVED_FROM_CART", username, productId, productName, quantity, price);
        log.info("Publishing ITEM_REMOVED_FROM_CART event: {}", event);
        kafkaTemplate.send(TOPIC_ITEM_REMOVED_FROM_CART, event.getEventId(), event);
    }

    public void publishCartUpdated(String username, Long productId, String productName, Integer quantity, Double price) {
        CartEvent event = new CartEvent("CART_UPDATED", username, productId, productName, quantity, price);
        log.info("Publishing CART_UPDATED event: {}", event);
        kafkaTemplate.send(TOPIC_CART_UPDATED, event.getEventId(), event);
    }

    public void publishCartCleared(String username) {
        CartEvent event = new CartEvent("CART_CLEARED", username, null, null, null, null);
        log.info("Publishing CART_CLEARED event: {}", event);
        kafkaTemplate.send(TOPIC_CART_CLEARED, event.getEventId(), event);
    }
}
