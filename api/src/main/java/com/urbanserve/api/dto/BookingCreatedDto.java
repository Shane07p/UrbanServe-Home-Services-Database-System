package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Result of placing a booking")
public record BookingCreatedDto(
    @Schema(example = "101") Integer bookingId,
    @Schema(example = "Booking placed successfully") String message
) {}
