package com.smartparking.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FloorResponse {
    private String floorId;
    private Integer floorNo;
    private Integer totalSlots;
    private Integer allottedSlots;
    private Integer availableSlots;
    private String parkingLotId;
    private List<ParkingSlotResponse> slots;
}
