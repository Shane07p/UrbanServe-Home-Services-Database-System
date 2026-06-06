package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Provider who has submitted all 3 required documents")
public record DocumentedProviderDto(
    @Schema(example = "3") Integer providerId,
    @Schema(example = "Professional plumbing services with 5+ years experience.") String bio
) {}
