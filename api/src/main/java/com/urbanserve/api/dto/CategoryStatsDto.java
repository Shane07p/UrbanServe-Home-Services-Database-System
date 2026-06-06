package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "Price statistics for a service category")
public record CategoryStatsDto(
    @Schema(example = "Electrical") String categoryName,
    @Schema(example = "4") Long totalServices,
    @Schema(example = "650.00") BigDecimal avgPrice,
    @Schema(example = "300.0") Double cheapest,
    @Schema(example = "1200.0") Double mostExpensive
) {}
