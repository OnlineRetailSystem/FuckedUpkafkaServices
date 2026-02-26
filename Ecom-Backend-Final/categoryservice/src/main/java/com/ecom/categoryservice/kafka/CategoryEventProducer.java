package com.ecom.categoryservice.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.ecom.categoryservice.events.CategoryEvent;

@Service
public class CategoryEventProducer {

    private static final Logger log = LoggerFactory.getLogger(CategoryEventProducer.class);

    private static final String TOPIC_CATEGORY_CREATED = "CATEGORY_CREATED";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CategoryEventProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishCategoryCreated(Long categoryId, String categoryName) {
        CategoryEvent event = new CategoryEvent("CATEGORY_CREATED", categoryId, categoryName);
        log.info("Publishing CATEGORY_CREATED event: {}", event);
        kafkaTemplate.send(TOPIC_CATEGORY_CREATED, event.getEventId(), event);
    }
}
