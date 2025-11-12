package com.smartparking.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParkingLotRequest {
    @NotBlank(message = "Name is required")
    private String name;

    private String address;

    @NotNull(message = "Total floors is required")
    @Min(value = 1, message = "At least 1 floor is required")
    private Integer totalFloors;
}
