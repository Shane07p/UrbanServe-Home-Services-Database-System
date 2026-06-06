package com.urbanserve.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "Category with average price above threshold")
public record ExpensiveCategoryDto(
    @Schema(example = "Electrical") String categoryName,
    @Schema(example = "875.00") BigDecimal avgPrice
) {}
