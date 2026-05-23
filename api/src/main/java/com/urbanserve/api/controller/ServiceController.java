package com.urbanserve.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
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
    public List<Map<String, Object>> getActiveServices(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return jdbc.queryForList("""
                SELECT service_id, service_name, base_price, duration
                FROM Service
                WHERE is_active = TRUE
                ORDER BY base_price DESC
                LIMIT ? OFFSET ?
                """, size, page * size);
    }

    @GetMapping("/search")
    @Operation(summary = "Search services by name keyword")
    public List<Map<String, Object>> searchServices(@RequestParam String name) {
        return jdbc.queryForList("""
                SELECT service_id, service_name, base_price, duration
                FROM Service
                WHERE service_name ILIKE ?
                ORDER BY base_price ASC
                """, "%" + name + "%");
    }

    @GetMapping("/category-stats")
    @Operation(summary = "Price statistics per category")
    public List<Map<String, Object>> getCategoryStats() {
        return jdbc.queryForList("""
                SELECT c.category_name,
                       COUNT(s.service_id) AS total_services,
                       ROUND(AVG(s.base_price)::numeric, 2) AS avg_price,
                       MIN(s.base_price) AS cheapest,
                       MAX(s.base_price) AS most_expensive
                FROM Category c
                JOIN Service s ON c.category_id = s.category_id
                GROUP BY c.category_name
                ORDER BY avg_price DESC
                """);
    }

    @GetMapping("/expensive-categories")
    @Operation(summary = "Categories where average price exceeds a threshold (default 600)")
    public List<Map<String, Object>> getExpensiveCategories(
            @RequestParam(defaultValue = "600") double minAvgPrice) {
        return jdbc.queryForList("""
                SELECT c.category_name,
                       ROUND(AVG(s.base_price)::numeric, 2) AS avg_price
                FROM Category c
                JOIN Service s ON c.category_id = s.category_id
                GROUP BY c.category_name
                HAVING AVG(s.base_price) > ?
                ORDER BY avg_price DESC
                """, minAvgPrice);
    }
}
