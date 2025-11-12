package com.smartparking.service;

import com.smartparking.dto.request.EmployeeRequest;
import com.smartparking.dto.response.EmployeeResponse;

import java.util.List;

public interface EmployeeService {
    EmployeeResponse createEmployee(EmployeeRequest request);
    EmployeeResponse getEmployeeById(String empId);
    EmployeeResponse getEmployeeByEmail(String email);
    List<EmployeeResponse> getAllEmployees();
    EmployeeResponse updateEmployee(String empId, EmployeeRequest request);
    void deleteEmployee(String empId);
}
