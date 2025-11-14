package com.smartparking.service;

import com.smartparking.dto.request.BillUpdateRequest;
import com.smartparking.dto.request.VehicleEntryRequest;
import com.smartparking.dto.response.VehicleResponse;

public interface ParkingService {
    VehicleResponse parkVehicle(VehicleEntryRequest request);
    VehicleResponse exitVehicle(String vehicleRegistration);
    VehicleResponse getVehicleByRegistration(String vehicleRegistration);
    VehicleResponse updateBillAmount(String vehicleId, BillUpdateRequest request);
}
