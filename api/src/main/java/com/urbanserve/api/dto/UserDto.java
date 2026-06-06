package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "User with no complaints filed")
public record UserDto(
    @Schema(example = "4") Integer userId,
    @Schema(example = "ananya.sharma@gmail.com") String email,
    @Schema(example = "Customer") String role
) {}
