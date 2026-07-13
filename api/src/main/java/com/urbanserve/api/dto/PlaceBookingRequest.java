package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request body to place a new booking")
public record PlaceBookingRequest(
    @Schema(example = "1") Integer customerId,
    @Schema(example = "6") Integer providerId,
    @Schema(example = "3") Integer addressId,
    @Schema(example = "1", description = "Optional — null for no coupon") Integer couponId,
    @Schema(example = "2024-06-01") String scheduledDate,
    @Schema(example = "10:00:00") String scheduledTime,
    @Schema(example = "800.0") Double totalAmount,
    @Schema(example = "Please bring own tools") String specialInstructions,
    @Schema(example = "2") Integer serviceId,
    @Schema(example = "1") Integer quantity,
    @Schema(example = "800.0") Double unitPrice
) {}
