package com.smartparking.service.impl;

import com.smartparking.dto.request.EmployeeRequest;
import com.smartparking.dto.response.EmployeeResponse;
import com.smartparking.entity.Employee;
import com.smartparking.exception.DuplicateResourceException;
import com.smartparking.exception.ResourceNotFoundException;
import com.smartparking.repository.EmployeeRepository;
import com.smartparking.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeRepository employeeRepository;

    @Override
    @Transactional
    public EmployeeResponse createEmployee(EmployeeRequest request) {
        if (employeeRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Employee with email " + request.getEmail() + " already exists");
        }

        Employee employee = Employee.builder()
                .name(request.getName())
                .email(request.getEmail())
                .phNo(request.getPhNo())
                .dob(request.getDob())
                .gender(request.getGender())
                .photo(request.getPhoto())
                .address(request.getAddress())
                .roles(request.getRoles())
                .build();

        employee = employeeRepository.save(employee);
        return mapToResponse(employee);
    }

    @Override
    public EmployeeResponse getEmployeeById(String empId) {
        Employee employee = employeeRepository.findById(empId)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + empId));
        return mapToResponse(employee);
    }

    @Override
    public EmployeeResponse getEmployeeByEmail(String email) {
        Employee employee = employeeRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with email: " + email));
        return mapToResponse(employee);
    }

    @Override
    public List<EmployeeResponse> getAllEmployees() {
        return employeeRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EmployeeResponse updateEmployee(String empId, EmployeeRequest request) {
        Employee employee = employeeRepository.findById(empId)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + empId));

        if (!employee.getEmail().equals(request.getEmail()) &&
                employeeRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Employee with email " + request.getEmail() + " already exists");
        }

        employee.setName(request.getName());
        employee.setEmail(request.getEmail());
        employee.setPhNo(request.getPhNo());
        employee.setDob(request.getDob());
        employee.setGender(request.getGender());
        employee.setPhoto(request.getPhoto());
        employee.setAddress(request.getAddress());
        employee.setRoles(request.getRoles());

        employee = employeeRepository.save(employee);
        return mapToResponse(employee);
    }

    @Override
    @Transactional
    public void deleteEmployee(String empId) {
        if (!employeeRepository.existsById(empId)) {
            throw new ResourceNotFoundException("Employee not found with id: " + empId);
        }
        employeeRepository.deleteById(empId);
    }

    private EmployeeResponse mapToResponse(Employee employee) {
        return EmployeeResponse.builder()
                .empId(employee.getEmpId())
                .name(employee.getName())
                .email(employee.getEmail())
                .phNo(employee.getPhNo())
                .dob(employee.getDob())
                .gender(employee.getGender())
                .photo(employee.getPhoto())
                .address(employee.getAddress())
                .roles(employee.getRoles())
                .createdAt(employee.getCreatedAt())
                .updatedAt(employee.getUpdatedAt())
                .build();
    }
}
