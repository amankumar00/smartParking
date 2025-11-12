package com.smartparking.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParkingLotResponse {
    private String parkingLotId;
    private String name;
    private String address;
    private Integer totalFloors;
    private List<FloorResponse> floors;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
