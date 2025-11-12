package com.smartparking.controller;

import com.smartparking.dto.response.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Map<String, Object>>> health() {
        Map<String, Object> healthData = new HashMap<>();
        healthData.put("status", "UP");
        healthData.put("timestamp", LocalDateTime.now());
        healthData.put("service", "Smart Parking Backend");
        healthData.put("version", "1.0.0");

        return ResponseEntity.ok(ApiResponse.success("Service is running", healthData));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, String>>> welcome() {
        Map<String, String> welcomeData = new HashMap<>();
        welcomeData.put("message", "Welcome to Smart Parking Backend API");
        welcomeData.put("documentation", "Refer to README.md for API documentation");
        welcomeData.put("healthCheck", "/api/health");

        return ResponseEntity.ok(ApiResponse.success("Smart Parking Backend API", welcomeData));
    }
}
