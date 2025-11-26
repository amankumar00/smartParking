-- Auto-load test data for development
-- This file runs automatically when Spring Boot starts
-- Note: spring.sql.init.continue-on-error=true means errors are ignored

-- Create test employee for frontend login
MERGE INTO employees KEY(email)
VALUES (
    'emp-bms-001',
    'BMS Admin',
    'bms@gmail.com',
    '9876543210',
    CURRENT_TIMESTAMP,
    null,
    null,
    null,
    'ADMIN',
    'Admin Office, Main Building',
    CURRENT_TIMESTAMP
);

-- You can add more test data here as needed
-- Use MERGE INTO for idempotent inserts (won't duplicate if already exists)