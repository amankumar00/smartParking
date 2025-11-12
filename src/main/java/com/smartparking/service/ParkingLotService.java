package com.smartparking.service;

import com.smartparking.dto.request.FloorRequest;
import com.smartparking.dto.request.ParkingLotRequest;
import com.smartparking.dto.response.FloorResponse;
import com.smartparking.dto.response.ParkingLotResponse;

import java.util.List;

public interface ParkingLotService {
    ParkingLotResponse createParkingLot(ParkingLotRequest request);
    ParkingLotResponse getParkingLotById(String parkingLotId);
    List<ParkingLotResponse> getAllParkingLots();
    FloorResponse addFloor(FloorRequest request);
    FloorResponse getFloorById(String floorId);
    List<FloorResponse> getFloorsByParkingLotId(String parkingLotId);
}
