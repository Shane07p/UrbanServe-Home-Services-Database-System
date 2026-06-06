package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Most expensive booking per customer")
public record ExpensiveBookingDto(
    @Schema(example = "2") Integer customerId,
    @Schema(example = "Rohan Mehta") String name,
    @Schema(example = "14") Integer bookingId,
    @Schema(example = "Completed") String status,
    @Schema(example = "3500.0") Double mostExpensiveBooking
) {}
