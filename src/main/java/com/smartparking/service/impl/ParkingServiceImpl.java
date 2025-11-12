package com.smartparking.service.impl;

import com.smartparking.dto.request.VehicleEntryRequest;
import com.smartparking.dto.response.VehicleResponse;
import com.smartparking.entity.ParkingSlot;
import com.smartparking.entity.Vehicle;
import com.smartparking.enums.SlotStatus;
import com.smartparking.enums.SlotType;
import com.smartparking.enums.VehicleStatus;
import com.smartparking.enums.VehicleType;
import com.smartparking.exception.InvalidOperationException;
import com.smartparking.exception.NoAvailableSlotException;
import com.smartparking.exception.ResourceNotFoundException;
import com.smartparking.repository.ParkingSlotRepository;
import com.smartparking.repository.VehicleRepository;
import com.smartparking.service.ParkingService;
import com.smartparking.service.strategy.PricingStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ParkingServiceImpl implements ParkingService {

    private final VehicleRepository vehicleRepository;
    private final ParkingSlotRepository parkingSlotRepository;
    private final PricingStrategy pricingStrategy;

    @Override
    @Transactional
    public VehicleResponse parkVehicle(VehicleEntryRequest request) {
        // Check if vehicle is already parked
        vehicleRepository.findByVehicleRegistrationAndStatus(
                        request.getVehicleRegistration(),
                        VehicleStatus.PARKED)
                .ifPresent(v -> {
                    throw new InvalidOperationException(
                            "Vehicle " + request.getVehicleRegistration() + " is already parked");
                });

        // Find appropriate slot type based on vehicle type
        SlotType requiredSlotType = mapVehicleTypeToSlotType(request.getVehicleType());

        // Find available slot
        ParkingSlot availableSlot = parkingSlotRepository
                .findFirstBySlotTypeAndSlotStatus(requiredSlotType, SlotStatus.AVAILABLE)
                .orElseThrow(() -> new NoAvailableSlotException(
                        "No available slot for " + request.getVehicleType()));

        // Create vehicle entry
        Vehicle vehicle = Vehicle.builder()
                .vehicleType(request.getVehicleType())
                .vehicleRegistration(request.getVehicleRegistration())
                .timeIn(LocalDateTime.now())
                .status(VehicleStatus.PARKED)
                .assignedSlot(availableSlot)
                .build();

        vehicle = vehicleRepository.save(vehicle);

        // Update slot status
        availableSlot.setSlotStatus(SlotStatus.OCCUPIED);
        availableSlot.setCurrentVehicle(vehicle);
        parkingSlotRepository.save(availableSlot);

        // Update floor allotted slots
        availableSlot.getFloor().incrementAllottedSlots();

        return mapToResponse(vehicle);
    }

    @Override
    @Transactional
    public VehicleResponse exitVehicle(String vehicleRegistration) {
        // Find parked vehicle
        Vehicle vehicle = vehicleRepository
                .findByVehicleRegistrationAndStatus(vehicleRegistration, VehicleStatus.PARKED)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "No parked vehicle found with registration: " + vehicleRegistration));

        // Calculate parking duration and bill
        LocalDateTime timeOut = LocalDateTime.now();
        Duration parkingDuration = Duration.between(vehicle.getTimeIn(), timeOut);
        double billAmount = pricingStrategy.calculatePrice(vehicle.getVehicleType(), parkingDuration);

        // Update vehicle
        vehicle.setTimeOut(timeOut);
        vehicle.setStatus(VehicleStatus.EXITED);
        vehicle.setBillAmt(billAmount);

        // Update slot status
        ParkingSlot slot = vehicle.getAssignedSlot();
        if (slot != null) {
            slot.setSlotStatus(SlotStatus.AVAILABLE);
            slot.setCurrentVehicle(null);
            parkingSlotRepository.save(slot);

            // Update floor allotted slots
            slot.getFloor().decrementAllottedSlots();
        }

        vehicle = vehicleRepository.save(vehicle);

        return mapToResponse(vehicle);
    }

    @Override
    public VehicleResponse getVehicleByRegistration(String vehicleRegistration) {
        Vehicle vehicle = vehicleRepository.findByVehicleRegistration(vehicleRegistration)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Vehicle not found with registration: " + vehicleRegistration));
        return mapToResponse(vehicle);
    }

    private SlotType mapVehicleTypeToSlotType(VehicleType vehicleType) {
        return switch (vehicleType) {
            case TWO_WHEELER -> SlotType.TWO_WHEELER;
            case FOUR_WHEELER -> SlotType.FOUR_WHEELER;
            case HEAVY_VEHICLE -> SlotType.HEAVY_VEHICLE;
        };
    }

    private VehicleResponse mapToResponse(Vehicle vehicle) {
        return VehicleResponse.builder()
                .vehicleId(vehicle.getVehicleId())
                .vehicleType(vehicle.getVehicleType())
                .vehicleRegistration(vehicle.getVehicleRegistration())
                .timeIn(vehicle.getTimeIn())
                .timeOut(vehicle.getTimeOut())
                .status(vehicle.getStatus())
                .billAmt(vehicle.getBillAmt())
                .assignedSlotId(vehicle.getAssignedSlot() != null ?
                        vehicle.getAssignedSlot().getSlotId() : null)
                .build();
    }
}
