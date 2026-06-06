package com.urbanserve.api.controller;

import com.urbanserve.api.dto.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/services")
@Tag(name = "Services", description = "Service catalog endpoints")
public class ServiceController {

    private final JdbcTemplate jdbc;

    public ServiceController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping
    @Operation(summary = "Active services paginated by price")
    public List<ServiceDto> getActiveServices(
            @Parameter(description = "Page number (0-based)", example = "0")
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Results per page", example = "10")
            @RequestParam(defaultValue = "10") int size) {
        return jdbc.query("""
                SELECT service_id, service_name, base_price, duration
                FROM Service
                WHERE is_active = TRUE
                ORDER BY base_price DESC
                LIMIT ? OFFSET ?
                """, DataClassRowMapper.newInstance(ServiceDto.class), size, page * size);
    }

    @GetMapping("/search")
    @Operation(summary = "Search services by name keyword")
    public ResponseEntity<?> searchServices(
            @Parameter(description = "Service name keyword to search for", example = "repair")
            @RequestParam String name) {
        List<ServiceDto> results = jdbc.query("""
                SELECT service_id, service_name, base_price, duration
                FROM Service
                WHERE service_name ILIKE ?
                ORDER BY base_price ASC
                """, DataClassRowMapper.newInstance(ServiceDto.class), "%" + name + "%");

        if (results.isEmpty()) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", "No services found matching '" + name + "'"));
        }
        return ResponseEntity.ok(results);
    }

    @GetMapping("/category-stats")
    @Operation(summary = "Price statistics per category")
    public List<CategoryStatsDto> getCategoryStats() {
        return jdbc.query("""
                SELECT c.category_name,
                       COUNT(s.service_id) AS total_services,
                       ROUND(AVG(s.base_price)::numeric, 2) AS avg_price,
                       MIN(s.base_price) AS cheapest,
                       MAX(s.base_price) AS most_expensive
                FROM Category c
                JOIN Service s ON c.category_id = s.category_id
                GROUP BY c.category_name
                ORDER BY avg_price DESC
                """, DataClassRowMapper.newInstance(CategoryStatsDto.class));
    }

    @GetMapping("/expensive-categories")
    @Operation(summary = "Categories where average price exceeds a threshold")
    public ResponseEntity<?> getExpensiveCategories(
            @Parameter(description = "Minimum average price threshold", example = "600")
            @RequestParam(defaultValue = "600") double minAvgPrice) {
        List<ExpensiveCategoryDto> results = jdbc.query("""
                SELECT c.category_name,
                       ROUND(AVG(s.base_price)::numeric, 2) AS avg_price
                FROM Category c
                JOIN Service s ON c.category_id = s.category_id
                GROUP BY c.category_name
                HAVING AVG(s.base_price) > ?
                ORDER BY avg_price DESC
                """, DataClassRowMapper.newInstance(ExpensiveCategoryDto.class), minAvgPrice);

        if (results.isEmpty()) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", "No categories found with average price above " + minAvgPrice));
        }
        return ResponseEntity.ok(results);
    }
}
