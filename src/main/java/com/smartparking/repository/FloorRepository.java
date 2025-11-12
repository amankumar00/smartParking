package com.smartparking.repository;

import com.smartparking.entity.Floor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FloorRepository extends JpaRepository<Floor, String> {
    List<Floor> findByParkingLotParkingLotId(String parkingLotId);
    Optional<Floor> findByParkingLotParkingLotIdAndFloorNo(String parkingLotId, Integer floorNo);
}
