package com.smartparking.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.config.file:firebase-service-account.json}")
    private String firebaseConfigFile;

    @Bean
    public FirebaseApp initializeFirebase() throws IOException {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = new ClassPathResource(firebaseConfigFile).getInputStream();

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp app = FirebaseApp.initializeApp(options);
                log.info("Firebase has been initialized successfully");
                return app;
            } else {
                log.info("Firebase already initialized");
                return FirebaseApp.getInstance();
            }
        } catch (Exception e) {
            log.error("Error initializing Firebase: {}. Make sure firebase-service-account.json is in resources folder", e.getMessage());
            // Don't throw exception to allow app to start without Firebase
            return null;
        }
    }
}
