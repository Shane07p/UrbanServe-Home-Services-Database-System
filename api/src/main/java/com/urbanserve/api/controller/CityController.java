package com.urbanserve.api.controller;

import com.urbanserve.api.dto.CityRevenueDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cities")
@Tag(name = "Cities", description = "City revenue and analytics endpoints")
public class CityController {

    private final JdbcTemplate jdbc;

    public CityController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/revenue")
    @Operation(summary = "City revenue summary — total bookings, revenue, and unique customers")
    public List<CityRevenueDto> getCityRevenue() {
        return jdbc.query("""
                SELECT city_name, state, total_bookings, completed_bookings,
                       cancelled_bookings, total_revenue, avg_booking_value,
                       unique_customers, active_providers
                FROM mv_city_revenue_summary
                ORDER BY total_revenue DESC NULLS LAST
                """, DataClassRowMapper.newInstance(CityRevenueDto.class));
    }
}
