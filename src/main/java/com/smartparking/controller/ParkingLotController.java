package com.smartparking.controller;

import com.smartparking.dto.request.FloorRequest;
import com.smartparking.dto.request.ParkingLotRequest;
import com.smartparking.dto.response.ApiResponse;
import com.smartparking.dto.response.FloorResponse;
import com.smartparking.dto.response.ParkingLotResponse;
import com.smartparking.service.ParkingLotService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/parking-lots")
@RequiredArgsConstructor
public class ParkingLotController {

    private final ParkingLotService parkingLotService;

    @PostMapping
    public ResponseEntity<ApiResponse<ParkingLotResponse>> createParkingLot(
            @Valid @RequestBody ParkingLotRequest request) {
        ParkingLotResponse response = parkingLotService.createParkingLot(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Parking lot created successfully", response));
    }

    @GetMapping("/{parkingLotId}")
    public ResponseEntity<ApiResponse<ParkingLotResponse>> getParkingLotById(
            @PathVariable String parkingLotId) {
        ParkingLotResponse response = parkingLotService.getParkingLotById(parkingLotId);
        return ResponseEntity.ok(ApiResponse.success("Parking lot retrieved successfully", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ParkingLotResponse>>> getAllParkingLots() {
        List<ParkingLotResponse> response = parkingLotService.getAllParkingLots();
        return ResponseEntity.ok(ApiResponse.success("Parking lots retrieved successfully", response));
    }

    @PostMapping("/floors")
    public ResponseEntity<ApiResponse<FloorResponse>> addFloor(
            @Valid @RequestBody FloorRequest request) {
        FloorResponse response = parkingLotService.addFloor(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Floor added successfully", response));
    }

    @GetMapping("/floors/{floorId}")
    public ResponseEntity<ApiResponse<FloorResponse>> getFloorById(
            @PathVariable String floorId) {
        FloorResponse response = parkingLotService.getFloorById(floorId);
        return ResponseEntity.ok(ApiResponse.success("Floor retrieved successfully", response));
    }

    @GetMapping("/{parkingLotId}/floors")
    public ResponseEntity<ApiResponse<List<FloorResponse>>> getFloorsByParkingLotId(
            @PathVariable String parkingLotId) {
        List<FloorResponse> response = parkingLotService.getFloorsByParkingLotId(parkingLotId);
        return ResponseEntity.ok(ApiResponse.success("Floors retrieved successfully", response));
    }
}
