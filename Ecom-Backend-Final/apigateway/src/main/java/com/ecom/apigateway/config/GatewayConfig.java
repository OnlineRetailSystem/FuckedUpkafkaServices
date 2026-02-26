package com.ecom.apigateway.config;

import com.ecom.apigateway.filter.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // Auth Service - Public endpoints (no JWT required)
                .route("authservice", r -> r
                        .path("/auth/**")
                        .filters(f -> f.stripPrefix(1))
                        .uri("lb://AUTHSERVICE"))

                // Product Service - Protected (JWT required)
                .route("productservice", r -> r
                        .path("/products/**")
                        .filters(f -> f.filter(jwtAuthenticationFilter))
                        .uri("lb://PRODUCTSERVICE"))

                // Cart Service - Protected (JWT required)
                .route("cartservice", r -> r
                        .path("/cart/**")
                        .filters(f -> f.filter(jwtAuthenticationFilter))
                        .uri("lb://CARTSERVICE"))

                // Order Service - Protected (JWT required)
                .route("orderservice", r -> r
                        .path("/orders/**")
                        .filters(f -> f.filter(jwtAuthenticationFilter))
                        .uri("lb://ORDERSERVICE"))

                // Payment Service - Protected (JWT required)
                .route("paymentservice", r -> r
                        .path("/payments/**")
                        .filters(f -> f.filter(jwtAuthenticationFilter))
                        .uri("lb://PAYMENTSERVICE"))

                // Category Service - Protected (JWT required)
                .route("categoryservice", r -> r
                        .path("/categories/**")
                        .filters(f -> f.filter(jwtAuthenticationFilter))
                        .uri("lb://CATEGORYSERVICE"))

                .build();
    }
}
