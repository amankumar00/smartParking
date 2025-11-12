package com.smartparking.dto.response;

import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParkingSlotResponse {
    private String slotId;
    private SlotStatus slotStatus;
    private SlotType slotType;
    private String floorId;
    private String currentVehicleId;
}
