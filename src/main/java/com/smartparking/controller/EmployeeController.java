package com.smartparking.controller;

import com.smartparking.dto.request.EmployeeRequest;
import com.smartparking.dto.response.ApiResponse;
import com.smartparking.dto.response.EmployeeResponse;
import com.smartparking.service.EmployeeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
public class EmployeeController {

    private final EmployeeService employeeService;

    @PostMapping
    public ResponseEntity<ApiResponse<EmployeeResponse>> createEmployee(
            @Valid @RequestBody EmployeeRequest request) {
        EmployeeResponse response = employeeService.createEmployee(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Employee created successfully", response));
    }

    @GetMapping("/{empId}")
    public ResponseEntity<ApiResponse<EmployeeResponse>> getEmployeeById(
            @PathVariable String empId) {
        EmployeeResponse response = employeeService.getEmployeeById(empId);
        return ResponseEntity.ok(ApiResponse.success("Employee retrieved successfully", response));
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<ApiResponse<EmployeeResponse>> getEmployeeByEmail(
            @PathVariable String email) {
        EmployeeResponse response = employeeService.getEmployeeByEmail(email);
        return ResponseEntity.ok(ApiResponse.success("Employee retrieved successfully", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<EmployeeResponse>>> getAllEmployees() {
        List<EmployeeResponse> response = employeeService.getAllEmployees();
        return ResponseEntity.ok(ApiResponse.success("Employees retrieved successfully", response));
    }

    @PutMapping("/{empId}")
    public ResponseEntity<ApiResponse<EmployeeResponse>> updateEmployee(
            @PathVariable String empId,
            @Valid @RequestBody EmployeeRequest request) {
        EmployeeResponse response = employeeService.updateEmployee(empId, request);
        return ResponseEntity.ok(ApiResponse.success("Employee updated successfully", response));
    }

    @DeleteMapping("/{empId}")
    public ResponseEntity<ApiResponse<Void>> deleteEmployee(@PathVariable String empId) {
        employeeService.deleteEmployee(empId);
        return ResponseEntity.ok(ApiResponse.success("Employee deleted successfully", null));
    }
}
