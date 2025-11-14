package com.smartparking.entity;

import com.smartparking.enums.VehicleStatus;
import com.smartparking.enums.VehicleType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "vehicles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "vehicle_id")
    private String vehicleId;

    @Enumerated(EnumType.STRING)
    @Column(name = "vehicle_type", nullable = false)
    private VehicleType vehicleType;

    @NotBlank(message = "Vehicle registration is required")
    @Column(name = "vehicle_registration", nullable = false)
    private String vehicleRegistration;

    @Column(name = "time_in", nullable = false)
    private LocalDateTime timeIn;

    @Column(name = "time_out")
    private LocalDateTime timeOut;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VehicleStatus status;

    @Column(name = "bill_amt")
    private Double billAmt;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_slot_id")
    private ParkingSlot assignedSlot;

    @PrePersist
    protected void onCreate() {
        if (timeIn == null) {
            timeIn = LocalDateTime.now();
        }
        if (status == null) {
            status = VehicleStatus.IN_PROCESS;
        }
    }
}
