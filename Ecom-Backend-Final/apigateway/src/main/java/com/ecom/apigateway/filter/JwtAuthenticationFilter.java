package com.ecom.apigateway.filter;

import com.ecom.apigateway.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.function.Predicate;

@Component
public class JwtAuthenticationFilter implements GatewayFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();

        // Allow CORS preflight requests (OPTIONS method)
        if ("OPTIONS".equalsIgnoreCase(request.getMethod().toString())) {
            return chain.filter(exchange);
        }

        // List of public endpoints that don't require JWT
        final List<String> publicEndpoints = List.of(
                "/auth/signup",
                "/auth/signin"
        );

        // Check if the request path is a public endpoint
        Predicate<ServerHttpRequest> isPublicEndpoint = r ->
                publicEndpoints.stream()
                        .anyMatch(uri -> r.getURI().getPath().contains(uri));

        // If it's a public endpoint, allow without JWT validation
        if (isPublicEndpoint.test(request)) {
            return chain.filter(exchange);
        }

        // For protected endpoints, validate JWT
        if (!request.getHeaders().containsKey("Authorization")) {
            ServerHttpResponse response = exchange.getResponse();
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return response.setComplete();
        }

        String authHeader = request.getHeaders().getFirst("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            ServerHttpResponse response = exchange.getResponse();
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return response.setComplete();
        }

        String token = authHeader.substring(7);

        try {
            if (!jwtUtil.validateToken(token)) {
                ServerHttpResponse response = exchange.getResponse();
                response.setStatusCode(HttpStatus.UNAUTHORIZED);
                return response.setComplete();
            }

            // Extract username and add to request header for downstream services
            String username = jwtUtil.extractUsername(token);
            ServerHttpRequest modifiedRequest = exchange.getRequest().mutate()
                    .header("X-User-Name", username)
                    .build();

            return chain.filter(exchange.mutate().request(modifiedRequest).build());

        } catch (Exception e) {
            ServerHttpResponse response = exchange.getResponse();
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return response.setComplete();
        }
    }
}
