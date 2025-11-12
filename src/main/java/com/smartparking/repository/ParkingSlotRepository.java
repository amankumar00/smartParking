package com.smartparking.repository;

import com.smartparking.entity.ParkingSlot;
import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ParkingSlotRepository extends JpaRepository<ParkingSlot, String> {
    List<ParkingSlot> findBySlotStatusAndSlotType(SlotStatus slotStatus, SlotType slotType);

    @Query("SELECT ps FROM ParkingSlot ps WHERE ps.floor.floorId = :floorId AND ps.slotStatus = :status")
    List<ParkingSlot> findByFloorIdAndStatus(String floorId, SlotStatus status);

    Optional<ParkingSlot> findFirstBySlotTypeAndSlotStatus(SlotType slotType, SlotStatus slotStatus);

    long countByFloorFloorIdAndSlotStatus(String floorId, SlotStatus slotStatus);
}
