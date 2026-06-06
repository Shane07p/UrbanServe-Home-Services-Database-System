package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Booking with coupon details")
public record BookingCouponDto(
    @Schema(example = "5") Integer bookingId,
    @Schema(example = "Rohan Mehta") String customerName,
    @Schema(example = "2200.0") Double totalAmount,
    @Schema(example = "Completed") String status,
    @Schema(example = "SAVE10") String couponUsed,
    @Schema(example = "150.0") String discount
) {}
