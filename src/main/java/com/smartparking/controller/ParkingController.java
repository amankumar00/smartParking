package com.smartparking.controller;

import com.smartparking.dto.request.BillUpdateRequest;
import com.smartparking.dto.request.VehicleEntryRequest;
import com.smartparking.dto.response.ApiResponse;
import com.smartparking.dto.response.VehicleResponse;
import com.smartparking.service.ParkingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/parking")
@RequiredArgsConstructor
public class ParkingController {

    private final ParkingService parkingService;

    @PostMapping("/entry")
    public ResponseEntity<ApiResponse<VehicleResponse>> parkVehicle(
            @Valid @RequestBody VehicleEntryRequest request) {
        VehicleResponse response = parkingService.parkVehicle(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Vehicle parked successfully", response));
    }

    @PostMapping("/exit/{vehicleRegistration}")
    public ResponseEntity<ApiResponse<VehicleResponse>> exitVehicle(
            @PathVariable String vehicleRegistration) {
        VehicleResponse response = parkingService.exitVehicle(vehicleRegistration);
        return ResponseEntity.ok(ApiResponse.success("Vehicle exited successfully. Bill generated.", response));
    }

    @GetMapping("/vehicle/{vehicleRegistration}")
    public ResponseEntity<ApiResponse<VehicleResponse>> getVehicle(
            @PathVariable String vehicleRegistration) {
        VehicleResponse response = parkingService.getVehicleByRegistration(vehicleRegistration);
        return ResponseEntity.ok(ApiResponse.success("Vehicle retrieved successfully", response));
    }

    @PutMapping("/bill/{vehicleId}")
    public ResponseEntity<ApiResponse<VehicleResponse>> updateBillAmount(
            @PathVariable String vehicleId,
            @Valid @RequestBody BillUpdateRequest request) {
        VehicleResponse response = parkingService.updateBillAmount(vehicleId, request);
        return ResponseEntity.ok(ApiResponse.success("Bill amount updated successfully", response));
    }
}
