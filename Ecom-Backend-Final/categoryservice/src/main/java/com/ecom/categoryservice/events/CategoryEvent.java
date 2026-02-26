package com.ecom.categoryservice.events;

import java.time.LocalDateTime;
import java.util.UUID;

public class CategoryEvent {

    private String eventId;
    private String eventType;
    private Long categoryId;
    private String categoryName;
    private LocalDateTime timestamp;

    public CategoryEvent() {
    }

    public CategoryEvent(String eventType, Long categoryId, String categoryName) {
        this.eventId = UUID.randomUUID().toString();
        this.eventType = eventType;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.timestamp = LocalDateTime.now();
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "CategoryEvent{" +
                "eventId='" + eventId + '\'' +
                ", eventType='" + eventType + '\'' +
                ", categoryId=" + categoryId +
                ", categoryName='" + categoryName + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
