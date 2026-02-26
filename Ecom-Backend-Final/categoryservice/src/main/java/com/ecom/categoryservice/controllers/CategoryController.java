package com.ecom.categoryservice.controllers;

import com.ecom.categoryservice.models.Category;
import com.ecom.categoryservice.repositories.CategoryRepository;
import com.ecom.categoryservice.clients.ProductClient;
import com.ecom.categoryservice.dto.ProductDTO;
import com.ecom.categoryservice.kafka.CategoryEventProducer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categories")
public class CategoryController {

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ProductClient productClient;

    @Autowired
    private CategoryEventProducer categoryEventProducer;

    @PostMapping
    public ResponseEntity<Category> addCategory(@RequestBody Category category) {
        Category saved = categoryRepository.save(category);
        
        // Publish Kafka event
        categoryEventProducer.publishCategoryCreated(saved.getId(), saved.getName());
        
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public ResponseEntity<List<Category>> getAllCategories() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    @GetMapping("/{categoryName}/products")
    public ResponseEntity<List<ProductDTO>> getProductsByCategory(@PathVariable String categoryName) {
        return ResponseEntity.ok(productClient.getProductsByCategory(categoryName));
    }
}
