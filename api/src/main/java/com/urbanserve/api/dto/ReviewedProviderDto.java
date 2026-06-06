package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Provider with at least one review")
public record ReviewedProviderDto(
    @Schema(example = "6") Integer providerId,
    @Schema(example = "AC servicing expert — all brands, split and window units.") String bio,
    @Schema(example = "4.93") Double avgRating,
    @Schema(example = "Verified") String verificationStatus
) {}
