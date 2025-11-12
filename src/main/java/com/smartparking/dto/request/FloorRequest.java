package com.smartparking.dto.request;

import com.smartparking.enums.SlotType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FloorRequest {
    @NotNull(message = "Floor number is required")
    @Min(value = 0, message = "Floor number must be non-negative")
    private Integer floorNo;

    @NotNull(message = "Parking lot ID is required")
    private String parkingLotId;

    @NotNull(message = "Slot configuration is required")
    private Map<SlotType, Integer> slotConfiguration;
}
