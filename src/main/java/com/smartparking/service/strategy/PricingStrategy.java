package com.smartparking.service.strategy;

import com.smartparking.enums.VehicleType;

import java.time.Duration;

public interface PricingStrategy {
    double calculatePrice(VehicleType vehicleType, Duration parkingDuration);
}
