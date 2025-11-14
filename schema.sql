-- Smart Parking Backend - PostgreSQL Database Schema
-- This schema matches your JPA entity definitions

-- Drop existing tables if they exist (careful in production!)
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS parking_slots CASCADE;
DROP TABLE IF EXISTS floors CASCADE;
DROP TABLE IF EXISTS parking_lots CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- =============================================================================
-- TABLE: employees
-- =============================================================================
CREATE TABLE employees (
    emp_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    ph_no VARCHAR(255),
    dob DATE,
    gender VARCHAR(50) CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    photo VARCHAR(500),
    address VARCHAR(500),
    roles VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

-- Index for faster email lookups
CREATE INDEX idx_employees_email ON employees(email);

-- =============================================================================
-- TABLE: parking_lots
-- =============================================================================
CREATE TABLE parking_lots (
    parking_lot_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    total_floors INTEGER,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

-- Index for faster name searches
CREATE INDEX idx_parking_lots_name ON parking_lots(name);

-- =============================================================================
-- TABLE: floors
-- =============================================================================
CREATE TABLE floors (
    floor_id VARCHAR(255) PRIMARY KEY,
    floor_no INTEGER NOT NULL,
    total_slots INTEGER NOT NULL,
    allotted_slots INTEGER NOT NULL,
    parking_lot_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_floors_parking_lot
        FOREIGN KEY (parking_lot_id)
        REFERENCES parking_lots(parking_lot_id)
        ON DELETE CASCADE
);

-- Index for faster parking lot queries
CREATE INDEX idx_floors_parking_lot_id ON floors(parking_lot_id);
-- Composite index for floor lookup within a parking lot
CREATE INDEX idx_floors_lot_floor_no ON floors(parking_lot_id, floor_no);

-- =============================================================================
-- TABLE: parking_slots
-- =============================================================================
CREATE TABLE parking_slots (
    slot_id VARCHAR(255) PRIMARY KEY,
    slot_status VARCHAR(50) NOT NULL CHECK (slot_status IN ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'MAINTENANCE')),
    slot_type VARCHAR(50) NOT NULL CHECK (slot_type IN ('TWO_WHEELER', 'FOUR_WHEELER', 'HEAVY_VEHICLE')),
    floor_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_parking_slots_floor
        FOREIGN KEY (floor_id)
        REFERENCES floors(floor_id)
        ON DELETE CASCADE
);

-- Indexes for faster slot searches
CREATE INDEX idx_parking_slots_floor_id ON parking_slots(floor_id);
CREATE INDEX idx_parking_slots_status ON parking_slots(slot_status);
CREATE INDEX idx_parking_slots_type ON parking_slots(slot_type);
-- Composite index for finding available slots by type
CREATE INDEX idx_parking_slots_status_type ON parking_slots(slot_status, slot_type);

-- =============================================================================
-- TABLE: vehicles
-- =============================================================================
CREATE TABLE vehicles (
    vehicle_id VARCHAR(255) PRIMARY KEY,
    vehicle_type VARCHAR(50) NOT NULL CHECK (vehicle_type IN ('TWO_WHEELER', 'FOUR_WHEELER', 'HEAVY_VEHICLE')),
    vehicle_registration VARCHAR(255) NOT NULL UNIQUE,
    time_in TIMESTAMP(6) NOT NULL,
    time_out TIMESTAMP(6),
    status VARCHAR(50) NOT NULL CHECK (status IN ('PARKED', 'EXITED', 'IN_PROCESS')),
    bill_amt DOUBLE PRECISION,
    assigned_slot_id VARCHAR(255) UNIQUE,
    CONSTRAINT fk_vehicles_parking_slot
        FOREIGN KEY (assigned_slot_id)
        REFERENCES parking_slots(slot_id)
        ON DELETE SET NULL
);

-- Indexes for faster vehicle searches
CREATE INDEX idx_vehicles_registration ON vehicles(vehicle_registration);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_time_in ON vehicles(time_in);
CREATE INDEX idx_vehicles_assigned_slot ON vehicles(assigned_slot_id);

-- =============================================================================
-- VIEWS (Optional - for convenience)
-- =============================================================================

-- View: Active Parking Sessions
CREATE OR REPLACE VIEW active_parking_sessions AS
SELECT
    v.vehicle_id,
    v.vehicle_registration,
    v.vehicle_type,
    v.time_in,
    v.status,
    ps.slot_id,
    ps.slot_type,
    f.floor_no,
    pl.name as parking_lot_name
FROM vehicles v
LEFT JOIN parking_slots ps ON v.assigned_slot_id = ps.slot_id
LEFT JOIN floors f ON ps.floor_id = f.floor_id
LEFT JOIN parking_lots pl ON f.parking_lot_id = pl.parking_lot_id
WHERE v.status IN ('PARKED', 'IN_PROCESS');

-- View: Parking Lot Occupancy
CREATE OR REPLACE VIEW parking_lot_occupancy AS
SELECT
    pl.parking_lot_id,
    pl.name,
    pl.total_floors,
    COUNT(DISTINCT f.floor_id) as actual_floors,
    SUM(f.total_slots) as total_slots,
    SUM(f.allotted_slots) as occupied_slots,
    SUM(f.total_slots) - SUM(f.allotted_slots) as available_slots,
    ROUND(100.0 * SUM(f.allotted_slots) / NULLIF(SUM(f.total_slots), 0), 2) as occupancy_percentage
FROM parking_lots pl
LEFT JOIN floors f ON pl.parking_lot_id = f.parking_lot_id
GROUP BY pl.parking_lot_id, pl.name, pl.total_floors;

-- View: Available Slots by Type
CREATE OR REPLACE VIEW available_slots_by_type AS
SELECT
    pl.parking_lot_id,
    pl.name as parking_lot_name,
    f.floor_id,
    f.floor_no,
    ps.slot_type,
    COUNT(*) as available_count
FROM parking_slots ps
JOIN floors f ON ps.floor_id = f.floor_id
JOIN parking_lots pl ON f.parking_lot_id = pl.parking_lot_id
WHERE ps.slot_status = 'AVAILABLE'
GROUP BY pl.parking_lot_id, pl.name, f.floor_id, f.floor_no, ps.slot_type
ORDER BY pl.name, f.floor_no, ps.slot_type;

-- =============================================================================
-- SAMPLE DATA (Optional - for testing)
-- =============================================================================

-- Insert sample parking lot
INSERT INTO parking_lots (parking_lot_id, name, address, total_floors, created_at, updated_at)
VALUES ('lot-001', 'Main Parking Complex', '123 Main Street, City', 3, NOW(), NOW());

-- Insert sample floors
INSERT INTO floors (floor_id, floor_no, total_slots, allotted_slots, parking_lot_id)
VALUES
    ('floor-001', 0, 50, 0, 'lot-001'),
    ('floor-002', 1, 50, 0, 'lot-001'),
    ('floor-003', 2, 50, 0, 'lot-001');

-- Insert sample parking slots for Floor 0
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
SELECT
    'slot-0-' || generate_series::text,
    'AVAILABLE',
    CASE
        WHEN generate_series <= 20 THEN 'TWO_WHEELER'
        WHEN generate_series <= 40 THEN 'FOUR_WHEELER'
        ELSE 'HEAVY_VEHICLE'
    END,
    'floor-001'
FROM generate_series(1, 50);

-- Insert sample employees
INSERT INTO employees (emp_id, name, email, ph_no, dob, gender, roles, created_at, updated_at)
VALUES
    ('emp-001', 'Admin User', 'admin@smartparking.com', '1234567890', '1990-01-01', 'MALE', 'ADMIN', NOW(), NOW()),
    ('emp-002', 'Manager User', 'manager@smartparking.com', '0987654321', '1992-05-15', 'FEMALE', 'MANAGER', NOW(), NOW());

-- =============================================================================
-- FUNCTIONS (Optional - for convenience)
-- =============================================================================

-- Function to get available slots count by type
CREATE OR REPLACE FUNCTION get_available_slots_count(
    p_parking_lot_id VARCHAR(255),
    p_slot_type VARCHAR(50)
)
RETURNS INTEGER AS $$
DECLARE
    slot_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO slot_count
    FROM parking_slots ps
    JOIN floors f ON ps.floor_id = f.floor_id
    WHERE f.parking_lot_id = p_parking_lot_id
      AND ps.slot_type = p_slot_type
      AND ps.slot_status = 'AVAILABLE';

    RETURN slot_count;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT get_available_slots_count('lot-001', 'TWO_WHEELER');

-- =============================================================================
-- GRANTS (Optional - for production)
-- =============================================================================

-- Grant permissions to the application user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO smartparking_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO smartparking_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO smartparking_user;

-- =============================================================================
-- END OF SCHEMA
-- =============================================================================

-- Verification queries
-- SELECT * FROM employees;
-- SELECT * FROM parking_lots;
-- SELECT * FROM floors;
-- SELECT * FROM parking_slots LIMIT 10;
-- SELECT * FROM vehicles;
-- SELECT * FROM active_parking_sessions;
-- SELECT * FROM parking_lot_occupancy;
-- SELECT * FROM available_slots_by_type;
