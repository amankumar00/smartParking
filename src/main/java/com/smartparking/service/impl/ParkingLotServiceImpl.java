package com.smartparking.service.impl;

import com.smartparking.dto.request.FloorRequest;
import com.smartparking.dto.request.ParkingLotRequest;
import com.smartparking.dto.response.FloorResponse;
import com.smartparking.dto.response.ParkingLotResponse;
import com.smartparking.dto.response.ParkingSlotResponse;
import com.smartparking.entity.Floor;
import com.smartparking.entity.ParkingLot;
import com.smartparking.entity.ParkingSlot;
import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import com.smartparking.exception.DuplicateResourceException;
import com.smartparking.exception.ResourceNotFoundException;
import com.smartparking.repository.FloorRepository;
import com.smartparking.repository.ParkingLotRepository;
import com.smartparking.repository.ParkingSlotRepository;
import com.smartparking.service.ParkingLotService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParkingLotServiceImpl implements ParkingLotService {

    private final ParkingLotRepository parkingLotRepository;
    private final FloorRepository floorRepository;
    private final ParkingSlotRepository parkingSlotRepository;

    @Override
    @Transactional
    public ParkingLotResponse createParkingLot(ParkingLotRequest request) {
        if (parkingLotRepository.findByName(request.getName()).isPresent()) {
            throw new DuplicateResourceException("Parking lot with name " + request.getName() + " already exists");
        }

        ParkingLot parkingLot = ParkingLot.builder()
                .name(request.getName())
                .address(request.getAddress())
                .totalFloors(request.getTotalFloors())
                .floors(new ArrayList<>())
                .build();

        parkingLot = parkingLotRepository.save(parkingLot);
        return mapToParkingLotResponse(parkingLot);
    }

    @Override
    public ParkingLotResponse getParkingLotById(String parkingLotId) {
        ParkingLot parkingLot = parkingLotRepository.findById(parkingLotId)
                .orElseThrow(() -> new ResourceNotFoundException("Parking lot not found with id: " + parkingLotId));
        return mapToParkingLotResponse(parkingLot);
    }

    @Override
    public List<ParkingLotResponse> getAllParkingLots() {
        return parkingLotRepository.findAll().stream()
                .map(this::mapToParkingLotResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public FloorResponse addFloor(FloorRequest request) {
        ParkingLot parkingLot = parkingLotRepository.findById(request.getParkingLotId())
                .orElseThrow(() -> new ResourceNotFoundException("Parking lot not found with id: " + request.getParkingLotId()));

        // Check if floor already exists
        if (floorRepository.findByParkingLotParkingLotIdAndFloorNo(request.getParkingLotId(), request.getFloorNo()).isPresent()) {
            throw new DuplicateResourceException("Floor " + request.getFloorNo() + " already exists in this parking lot");
        }

        // Calculate total slots
        int totalSlots = request.getSlotConfiguration().values().stream()
                .mapToInt(Integer::intValue)
                .sum();

        Floor floor = Floor.builder()
                .floorNo(request.getFloorNo())
                .totalSlots(totalSlots)
                .allottedSlots(0)
                .parkingLot(parkingLot)
                .slots(new ArrayList<>())
                .build();

        floor = floorRepository.save(floor);

        // Create slots based on configuration
        List<ParkingSlot> slots = new ArrayList<>();
        for (Map.Entry<SlotType, Integer> entry : request.getSlotConfiguration().entrySet()) {
            SlotType slotType = entry.getKey();
            Integer count = entry.getValue();

            for (int i = 0; i < count; i++) {
                ParkingSlot slot = ParkingSlot.builder()
                        .slotStatus(SlotStatus.AVAILABLE)
                        .slotType(slotType)
                        .floor(floor)
                        .build();
                slots.add(slot);
            }
        }

        slots = parkingSlotRepository.saveAll(slots);
        floor.setSlots(slots);

        return mapToFloorResponse(floor);
    }

    @Override
    public FloorResponse getFloorById(String floorId) {
        Floor floor = floorRepository.findById(floorId)
                .orElseThrow(() -> new ResourceNotFoundException("Floor not found with id: " + floorId));
        return mapToFloorResponse(floor);
    }

    @Override
    public List<FloorResponse> getFloorsByParkingLotId(String parkingLotId) {
        if (!parkingLotRepository.existsById(parkingLotId)) {
            throw new ResourceNotFoundException("Parking lot not found with id: " + parkingLotId);
        }

        return floorRepository.findByParkingLotParkingLotId(parkingLotId).stream()
                .map(this::mapToFloorResponse)
                .collect(Collectors.toList());
    }

    private ParkingLotResponse mapToParkingLotResponse(ParkingLot parkingLot) {
        List<FloorResponse> floors = parkingLot.getFloors() != null ?
                parkingLot.getFloors().stream()
                        .map(this::mapToFloorResponse)
                        .collect(Collectors.toList()) :
                new ArrayList<>();

        return ParkingLotResponse.builder()
                .parkingLotId(parkingLot.getParkingLotId())
                .name(parkingLot.getName())
                .address(parkingLot.getAddress())
                .totalFloors(parkingLot.getTotalFloors())
                .floors(floors)
                .createdAt(parkingLot.getCreatedAt())
                .updatedAt(parkingLot.getUpdatedAt())
                .build();
    }

    private FloorResponse mapToFloorResponse(Floor floor) {
        List<ParkingSlotResponse> slots = floor.getSlots() != null ?
                floor.getSlots().stream()
                        .map(this::mapToSlotResponse)
                        .collect(Collectors.toList()) :
                new ArrayList<>();

        return FloorResponse.builder()
                .floorId(floor.getFloorId())
                .floorNo(floor.getFloorNo())
                .totalSlots(floor.getTotalSlots())
                .allottedSlots(floor.getAllottedSlots())
                .availableSlots(floor.getTotalSlots() - floor.getAllottedSlots())
                .parkingLotId(floor.getParkingLot().getParkingLotId())
                .slots(slots)
                .build();
    }

    private ParkingSlotResponse mapToSlotResponse(ParkingSlot slot) {
        return ParkingSlotResponse.builder()
                .slotId(slot.getSlotId())
                .slotStatus(slot.getSlotStatus())
                .slotType(slot.getSlotType())
                .floorId(slot.getFloor().getFloorId())
                .currentVehicleId(slot.getCurrentVehicle() != null ? slot.getCurrentVehicle().getVehicleId() : null)
                .build();
    }
}
