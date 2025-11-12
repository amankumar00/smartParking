package com.smartparking.service;

import com.smartparking.dto.response.UserInfoResponse;

public interface AuthService {
    UserInfoResponse getUserInfo(String uid);
    UserInfoResponse getCurrentUser();
}
