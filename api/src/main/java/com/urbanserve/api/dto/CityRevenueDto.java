package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "City-level revenue and booking statistics")
public record CityRevenueDto(
    @Schema(example = "Mumbai") String cityName,
    @Schema(example = "Maharashtra") String state,
    @Schema(example = "18") Long totalBookings,
    @Schema(example = "12") Long completedBookings,
    @Schema(example = "3") Long cancelledBookings,
    @Schema(example = "28500.00") BigDecimal totalRevenue,
    @Schema(example = "2375.00") BigDecimal avgBookingValue,
    @Schema(example = "7") Long uniqueCustomers,
    @Schema(example = "4") Long activeProviders
) {}
