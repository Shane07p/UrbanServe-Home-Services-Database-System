package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Provider leaderboard entry")
public record LeaderboardDto(
    @Schema(example = "6") Integer providerId,
    @Schema(example = "AC servicing expert — all brands, split and window units.") String providerBio,
    @Schema(example = "4.93") Double avgRating,
    @Schema(example = "12") Long totalReviews,
    @Schema(example = "4.92") Double computedAvgRating,
    @Schema(example = "28") Long totalBookings
) {}
