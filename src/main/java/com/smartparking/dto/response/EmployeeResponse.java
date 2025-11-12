package com.smartparking.dto.response;

import com.smartparking.enums.Gender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmployeeResponse {
    private String empId;
    private String name;
    private String email;
    private String phNo;
    private LocalDate dob;
    private Gender gender;
    private String photo;
    private String address;
    private String roles;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
