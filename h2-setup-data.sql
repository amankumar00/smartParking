-- H2 Database Setup Data for Smart Parking Backend
-- Run this in H2 Console: http://localhost:8080/h2-console

-- Clear existing data (if any)
DELETE FROM vehicles;
DELETE FROM parking_slots;
DELETE FROM floors;
DELETE FROM parking_lots;
DELETE FROM employees;

-- Create Parking Lot
INSERT INTO parking_lots (parking_lot_id, name, address, total_floors, created_at, updated_at)
VALUES ('lot-main-001', 'Main Smart Parking', '123 Main Street, City Center', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Create Floors
INSERT INTO floors (floor_id, floor_no, total_slots, allotted_slots, parking_lot_id)
VALUES
    ('floor-0', 0, 45, 0, 'lot-main-001'),
    ('floor-1', 1, 50, 0, 'lot-main-001'),
    ('floor-2', 2, 50, 0, 'lot-main-001');

-- Create Parking Slots for Floor 0 (Ground Floor)
-- TWO_WHEELER slots (15 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f0-tw-001', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-002', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-003', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-004', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-005', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-006', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-007', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-008', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-009', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-010', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-011', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-012', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-013', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-014', 'AVAILABLE', 'TWO_WHEELER', 'floor-0'),
    ('slot-f0-tw-015', 'AVAILABLE', 'TWO_WHEELER', 'floor-0');

-- FOUR_WHEELER slots for Floor 0 (25 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f0-fw-001', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-002', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-003', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-004', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-005', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-006', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-007', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-008', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-009', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-010', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-011', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-012', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-013', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-014', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-015', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-016', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-017', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-018', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-019', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-020', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-021', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-022', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-023', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-024', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0'),
    ('slot-f0-fw-025', 'AVAILABLE', 'FOUR_WHEELER', 'floor-0');

-- HEAVY_VEHICLE slots for Floor 0 (5 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f0-hv-001', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-0'),
    ('slot-f0-hv-002', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-0'),
    ('slot-f0-hv-003', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-0'),
    ('slot-f0-hv-004', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-0'),
    ('slot-f0-hv-005', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-0');

-- Create Parking Slots for Floor 1
-- TWO_WHEELER slots (20 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f1-tw-001', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-002', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-003', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-004', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-005', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-006', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-007', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-008', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-009', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-010', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-011', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-012', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-013', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-014', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-015', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-016', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-017', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-018', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-019', 'AVAILABLE', 'TWO_WHEELER', 'floor-1'),
    ('slot-f1-tw-020', 'AVAILABLE', 'TWO_WHEELER', 'floor-1');

-- FOUR_WHEELER slots for Floor 1 (30 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f1-fw-001', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-002', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-003', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-004', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-005', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-006', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-007', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-008', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-009', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-010', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-011', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-012', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-013', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-014', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-015', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-016', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-017', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-018', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-019', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-020', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-021', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-022', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-023', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-024', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-025', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-026', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-027', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-028', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-029', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1'),
    ('slot-f1-fw-030', 'AVAILABLE', 'FOUR_WHEELER', 'floor-1');

-- Create Parking Slots for Floor 2
-- TWO_WHEELER slots (25 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f2-tw-001', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-002', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-003', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-004', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-005', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-006', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-007', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-008', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-009', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-010', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-011', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-012', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-013', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-014', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-015', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-016', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-017', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-018', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-019', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-020', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-021', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-022', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-023', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-024', 'AVAILABLE', 'TWO_WHEELER', 'floor-2'),
    ('slot-f2-tw-025', 'AVAILABLE', 'TWO_WHEELER', 'floor-2');

-- FOUR_WHEELER slots for Floor 2 (20 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f2-fw-001', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-002', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-003', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-004', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-005', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-006', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-007', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-008', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-009', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-010', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-011', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-012', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-013', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-014', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-015', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-016', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-017', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-018', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-019', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2'),
    ('slot-f2-fw-020', 'AVAILABLE', 'FOUR_WHEELER', 'floor-2');

-- HEAVY_VEHICLE slots for Floor 2 (5 slots)
INSERT INTO parking_slots (slot_id, slot_status, slot_type, floor_id)
VALUES
    ('slot-f2-hv-001', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-2'),
    ('slot-f2-hv-002', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-2'),
    ('slot-f2-hv-003', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-2'),
    ('slot-f2-hv-004', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-2'),
    ('slot-f2-hv-005', 'AVAILABLE', 'HEAVY_VEHICLE', 'floor-2');

-- Verification queries
SELECT 'Parking Lots:' as info, COUNT(*) as count FROM parking_lots;
SELECT 'Floors:' as info, COUNT(*) as count FROM floors;
SELECT 'Total Slots:' as info, COUNT(*) as count FROM parking_slots;
SELECT 'TWO_WHEELER Slots:' as info, COUNT(*) as count FROM parking_slots WHERE slot_type = 'TWO_WHEELER';
SELECT 'FOUR_WHEELER Slots:' as info, COUNT(*) as count FROM parking_slots WHERE slot_type = 'FOUR_WHEELER';
SELECT 'HEAVY_VEHICLE Slots:' as info, COUNT(*) as count FROM parking_slots WHERE slot_type = 'HEAVY_VEHICLE';
