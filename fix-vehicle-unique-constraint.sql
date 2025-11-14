-- Fix for vehicle re-entry issue
-- This script removes the unique constraint on vehicle_registration column
-- allowing vehicles to park multiple times (with different sessions tracked by status)

-- For H2 Database (development)
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS uk_vehicle_registration;
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS UK_VEHICLE_REGISTRATION;

-- For PostgreSQL (production - if needed)
-- ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS vehicles_vehicle_registration_key;

-- Verify the constraint is removed
-- You can check with: SELECT * FROM INFORMATION_SCHEMA.CONSTRAINTS WHERE TABLE_NAME = 'VEHICLES';
