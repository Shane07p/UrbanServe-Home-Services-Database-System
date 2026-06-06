package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Booking summary with customer, provider, and location details")
public record BookingDto(
    @Schema(example = "1") Integer bookingId,
    @Schema(example = "Completed") String bookingStatus,
    @Schema(example = "Ananya Sharma") String customerName,
    @Schema(example = "AC servicing expert — all brands, split and window units.") String providerBio,
    @Schema(example = "Mumbai") String cityName,
    @Schema(example = "Andheri") String areaName,
    @Schema(example = "2024-03-15") Object scheduledDate,
    @Schema(example = "10:00:00") Object scheduledTime,
    @Schema(example = "1500.0") Double totalAmount
) {}
