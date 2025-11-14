package com.smartparking.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillUpdateRequest {

    @NotNull(message = "Bill amount is required")
    @Positive(message = "Bill amount must be positive")
    private Double billAmt;

    // Optional: Store pricing calculation details for audit/debugging
    private Map<String, Object> pricingDetails;
}
