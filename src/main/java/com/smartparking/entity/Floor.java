package com.smartparking.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "floors")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Floor {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "floor_id")
    private String floorId;

    @Column(name = "floor_no", nullable = false)
    private Integer floorNo;

    @Column(name = "total_slots", nullable = false)
    private Integer totalSlots;

    @Column(name = "allotted_slots", nullable = false)
    private Integer allottedSlots;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parking_lot_id", nullable = false)
    private ParkingLot parkingLot;

    @OneToMany(mappedBy = "floor", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ParkingSlot> slots = new ArrayList<>();

    public void incrementAllottedSlots() {
        this.allottedSlots++;
    }

    public void decrementAllottedSlots() {
        if (this.allottedSlots > 0) {
            this.allottedSlots--;
        }
    }
}
