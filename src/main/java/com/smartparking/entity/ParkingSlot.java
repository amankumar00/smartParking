package com.smartparking.entity;

import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "parking_slots")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ParkingSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "slot_id")
    private String slotId;

    @Enumerated(EnumType.STRING)
    @Column(name = "slot_status", nullable = false)
    private SlotStatus slotStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "slot_type", nullable = false)
    private SlotType slotType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "floor_id", nullable = false)
    private Floor floor;

    @OneToOne(mappedBy = "assignedSlot", cascade = CascadeType.ALL)
    private Vehicle currentVehicle;
}
