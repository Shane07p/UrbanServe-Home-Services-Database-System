package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Active service listing")
public record ServiceDto(
    @Schema(example = "3") Integer serviceId,
    @Schema(example = "AC Repair") String serviceName,
    @Schema(example = "500.0") Double basePrice,
    @Schema(example = "60") Integer duration
) {}
