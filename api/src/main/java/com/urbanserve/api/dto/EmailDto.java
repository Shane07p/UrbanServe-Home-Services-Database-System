package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Email entry with user type")
public record EmailDto(
    @Schema(example = "ananya.sharma@gmail.com") String email,
    @Schema(example = "Customer") String userType
) {}
