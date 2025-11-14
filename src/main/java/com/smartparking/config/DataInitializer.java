package com.smartparking.config;

import com.smartparking.entity.Floor;
import com.smartparking.entity.ParkingLot;
import com.smartparking.entity.ParkingSlot;
import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import com.smartparking.repository.FloorRepository;
import com.smartparking.repository.ParkingLotRepository;
import com.smartparking.repository.ParkingSlotRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final ParkingLotRepository parkingLotRepository;
    private final FloorRepository floorRepository;
    private final ParkingSlotRepository parkingSlotRepository;

    @Override
    public void run(String... args) {
        // Check if data already exists
        if (parkingLotRepository.count() > 0) {
            log.info("Parking data already exists. Skipping initialization.");
            return;
        }

        log.info("Initializing parking lot data...");

        // Create main parking lot
        ParkingLot mainLot = ParkingLot.builder()
                .parkingLotId("lot-main-001")
                .name("Main Smart Parking")
                .address("123 Main Street, City Center")
                .totalFloors(3)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        parkingLotRepository.save(mainLot);
        log.info("Created parking lot: {}", mainLot.getName());

        // Create floors and slots
        createFloor(mainLot, 0, 15, 25, 5);  // Floor 0: 15 TW, 25 FW, 5 HV = 45 total
        createFloor(mainLot, 1, 20, 25, 5);  // Floor 1: 20 TW, 25 FW, 5 HV = 50 total
        createFloor(mainLot, 2, 20, 25, 5);  // Floor 2: 20 TW, 25 FW, 5 HV = 50 total

        long totalSlots = parkingSlotRepository.count();
        log.info("Parking lot initialization complete! Total slots created: {}", totalSlots);
    }

    private void createFloor(ParkingLot lot, int floorNo, int twoWheelerSlots,
                            int fourWheelerSlots, int heavyVehicleSlots) {
        int totalSlots = twoWheelerSlots + fourWheelerSlots + heavyVehicleSlots;

        Floor floor = Floor.builder()
                .floorId("floor-" + floorNo)
                .floorNo(floorNo)
                .totalSlots(totalSlots)
                .allottedSlots(0)
                .parkingLot(lot)
                .build();
        floorRepository.save(floor);
        log.info("Created Floor {}: {} total slots", floorNo, totalSlots);

        List<ParkingSlot> slots = new ArrayList<>();

        // Create TWO_WHEELER slots
        for (int i = 1; i <= twoWheelerSlots; i++) {
            slots.add(createSlot(String.format("slot-f%d-tw-%03d", floorNo, i),
                                SlotType.TWO_WHEELER, floor));
        }

        // Create FOUR_WHEELER slots
        for (int i = 1; i <= fourWheelerSlots; i++) {
            slots.add(createSlot(String.format("slot-f%d-fw-%03d", floorNo, i),
                                SlotType.FOUR_WHEELER, floor));
        }

        // Create HEAVY_VEHICLE slots
        for (int i = 1; i <= heavyVehicleSlots; i++) {
            slots.add(createSlot(String.format("slot-f%d-hv-%03d", floorNo, i),
                                SlotType.HEAVY_VEHICLE, floor));
        }

        parkingSlotRepository.saveAll(slots);
        log.info("  - Created {} TWO_WHEELER slots", twoWheelerSlots);
        log.info("  - Created {} FOUR_WHEELER slots", fourWheelerSlots);
        log.info("  - Created {} HEAVY_VEHICLE slots", heavyVehicleSlots);
    }

    private ParkingSlot createSlot(String slotId, SlotType slotType, Floor floor) {
        return ParkingSlot.builder()
                .slotId(slotId)
                .slotType(slotType)
                .slotStatus(SlotStatus.AVAILABLE)
                .floor(floor)
                .build();
    }
}
