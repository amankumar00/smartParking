package com.smartparking.controller;

import com.smartparking.dto.response.ApiResponse;
import com.smartparking.dto.response.UserInfoResponse;
import com.smartparking.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserInfoResponse>> getCurrentUser() {
        UserInfoResponse userInfo = authService.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success("User info retrieved successfully", userInfo));
    }

    @GetMapping("/user/{uid}")
    public ResponseEntity<ApiResponse<UserInfoResponse>> getUserInfo(@PathVariable String uid) {
        UserInfoResponse userInfo = authService.getUserInfo(uid);
        return ResponseEntity.ok(ApiResponse.success("User info retrieved successfully", userInfo));
    }

    @PostMapping("/verify-token")
    public ResponseEntity<ApiResponse<String>> verifyToken() {
        // If this endpoint is reached, it means the token was valid (verified by the filter)
        return ResponseEntity.ok(ApiResponse.success("Token is valid", "Token verified successfully"));
    }
}
