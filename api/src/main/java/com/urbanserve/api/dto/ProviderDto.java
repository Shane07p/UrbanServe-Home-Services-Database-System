package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Verified service provider")
public record ProviderDto(
    @Schema(example = "7") Integer providerId,
    @Schema(example = "nitin.tech@gmail.com") String email,
    @Schema(example = "8") Integer experienceYears,
    @Schema(example = "Hardware and software laptop repair specialist. Certified by Dell & HP.") String bio,
    @Schema(example = "4.68") Double avgRating,
    @Schema(example = "Verified") String verificationStatus
) {}
