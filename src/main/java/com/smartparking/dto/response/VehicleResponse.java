package com.smartparking.dto.response;

import com.smartparking.enums.VehicleStatus;
import com.smartparking.enums.VehicleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VehicleResponse {
    private String vehicleId;
    private VehicleType vehicleType;
    private String vehicleRegistration;
    private LocalDateTime timeIn;
    private LocalDateTime timeOut;
    private VehicleStatus status;
    private Double billAmt;
    private String assignedSlotId;
}
