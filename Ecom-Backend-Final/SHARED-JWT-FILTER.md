# Shared JWT Filter for All Services

This guide shows how to add JWT validation to each microservice without changing business logic.

## Files to Copy to Each Service

### 1. JwtUtil.java (Copy to each service)

Location: `src/main/java/com/ecom/{service}/util/JwtUtil.java`

```java
package com.ecom.{service}.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret:mySecretKeyForJWTTokenGenerationThatIsAtLeast256BitsLong12345678}")
    private String secret;

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String extractUsername(String token) {
        return extractClaims(token).getSubject();
    }

    public String extractRoles(String token) {
        return (String) extractClaims(token).get("roles");
    }

    public Date extractExpiration(String token) {
        return extractClaims(token).getExpiration();
    }

    private Claims extractClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token) {
        try {
            return !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }
}
```

### 2. JwtAuthenticationFilter.java (Copy to each service)

Location: `src/main/java/com/ecom/{service}/filter/JwtAuthenticationFilter.java`

```java
package com.ecom.{service}.filter;

import com.ecom.{service}.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            try {
                if (jwtUtil.validateToken(token)) {
                    String username = jwtUtil.extractUsername(token);
                    String roles = jwtUtil.extractRoles(token);

                    // Convert roles string to authorities
                    List<SimpleGrantedAuthority> authorities = Arrays.stream(roles.split(","))
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList());

                    // Set authentication in context
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(username, null, authorities);

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            } catch (Exception e) {
                // Invalid token - continue without authentication
                logger.warn("JWT validation failed: " + e.getMessage());
            }
        }

        filterChain.doFilter(request, response);
    }
}
```

### 3. SecurityConfig.java (Update in each service)

Location: `src/main/java/com/ecom/{service}/security/SecurityConfig.java`

```java
package com.ecom.{service}.security;

import com.ecom.{service}.filter.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll() // Allow all requests (JWT is optional)
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

## Add JWT Dependencies to Each Service

Add to `pom.xml`:

```xml
<!-- JWT Dependencies -->
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-api</artifactId>
  <version>0.11.5</version>
</dependency>
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-impl</artifactId>
  <version>0.11.5</version>
  <scope>runtime</scope>
</dependency>
<dependency>
  <groupId>io.jsonwebtoken</groupId>
  <artifactId>jjwt-jackson</artifactId>
  <version>0.11.5</version>
  <scope>runtime</scope>
</dependency>
```

## Add Configuration to application.properties

```properties
# JWT Configuration (must match auth service)
jwt.secret=mySecretKeyForJWTTokenGenerationThatIsAtLeast256BitsLong12345678
```

## Services to Update

1. ✅ **Auth Service** - Already has JWT generation
2. ⏳ **Product Service** - Add JWT validation
3. ⏳ **Cart Service** - Add JWT validation
4. ⏳ **Order Service** - Add JWT validation
5. ⏳ **Payment Service** - Add JWT validation
6. ⏳ **Category Service** - Add JWT validation

## How It Works

### Without JWT Token:
```
Request → Service → Process → Response
```

### With JWT Token:
```
Request with "Authorization: Bearer <token>"
  ↓
JWT Filter validates token
  ↓
Extract username and roles
  ↓
Set in SecurityContext
  ↓
Service can access user info via SecurityContextHolder
  ↓
Process → Response
```

## Accessing User Info in Controllers

```java
import org.springframework.security.core.context.SecurityContextHolder;

@GetMapping("/my-orders")
public ResponseEntity<?> getMyOrders() {
    // Get username from JWT token
    String username = SecurityContextHolder.getContext()
        .getAuthentication()
        .getName();
    
    // Use username in business logic
    List<Order> orders = orderRepository.findByUsername(username);
    return ResponseEntity.ok(orders);
}
```

## Important Notes

✅ **No Business Logic Changes** - Existing code works as-is
✅ **JWT is Optional** - Services work with or without JWT
✅ **Backward Compatible** - Old requests still work
✅ **Stateless** - No session storage needed
✅ **Secure** - Tokens are cryptographically signed

## Testing

### Without JWT (still works):
```cmd
curl http://localhost:8090/products
```

### With JWT:
```cmd
curl http://localhost:8090/products ^
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

## Quick Setup Script

I'll create individual scripts for each service to automate this setup.
