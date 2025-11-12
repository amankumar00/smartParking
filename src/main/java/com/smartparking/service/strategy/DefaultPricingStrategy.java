package com.smartparking.service.strategy;

import com.smartparking.enums.VehicleType;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
public class DefaultPricingStrategy implements PricingStrategy {

    private static final double TWO_WHEELER_BASE_RATE = 10.0;  // per hour
    private static final double FOUR_WHEELER_BASE_RATE = 20.0; // per hour
    private static final double HEAVY_VEHICLE_BASE_RATE = 40.0; // per hour
    private static final double MINIMUM_CHARGE = 5.0;

    @Override
    public double calculatePrice(VehicleType vehicleType, Duration parkingDuration) {
        double hours = parkingDuration.toMinutes() / 60.0;

        // Minimum charge for less than 30 minutes
        if (hours < 0.5) {
            return MINIMUM_CHARGE;
        }

        double baseRate = switch (vehicleType) {
            case TWO_WHEELER -> TWO_WHEELER_BASE_RATE;
            case FOUR_WHEELER -> FOUR_WHEELER_BASE_RATE;
            case HEAVY_VEHICLE -> HEAVY_VEHICLE_BASE_RATE;
        };

        // Calculate total price
        double totalPrice = baseRate * Math.ceil(hours);

        return Math.round(totalPrice * 100.0) / 100.0; // Round to 2 decimal places
    }
}
