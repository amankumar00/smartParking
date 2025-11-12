package com.smartparking.service.impl;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.smartparking.dto.response.UserInfoResponse;
import com.smartparking.exception.ResourceNotFoundException;
import com.smartparking.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    @Override
    public UserInfoResponse getUserInfo(String uid) {
        try {
            UserRecord userRecord = FirebaseAuth.getInstance().getUser(uid);
            return mapToUserInfoResponse(userRecord);
        } catch (FirebaseAuthException e) {
            log.error("Error getting user info for uid: {}", uid, e);
            throw new ResourceNotFoundException("User not found with uid: " + uid);
        }
    }

    @Override
    public UserInfoResponse getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new ResourceNotFoundException("No authenticated user found");
        }

        String uid = authentication.getPrincipal().toString();
        return getUserInfo(uid);
    }

    private UserInfoResponse mapToUserInfoResponse(UserRecord userRecord) {
        return UserInfoResponse.builder()
                .uid(userRecord.getUid())
                .email(userRecord.getEmail())
                .displayName(userRecord.getDisplayName())
                .photoUrl(userRecord.getPhotoUrl())
                .emailVerified(userRecord.isEmailVerified())
                .build();
    }
}
