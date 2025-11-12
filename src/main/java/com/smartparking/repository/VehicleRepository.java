package com.smartparking.repository;

import com.smartparking.entity.Vehicle;
import com.smartparking.enums.VehicleStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, String> {
    Optional<Vehicle> findByVehicleRegistration(String vehicleRegistration);
    List<Vehicle> findByStatus(VehicleStatus status);
    Optional<Vehicle> findByVehicleRegistrationAndStatus(String vehicleRegistration, VehicleStatus status);
}
