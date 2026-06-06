package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Customer basic info")
public record CustomerDto(
    @Schema(example = "1") Integer customerId,
    @Schema(example = "Ananya Sharma") String name,
    @Schema(example = "9876543210") String phone
) {}
