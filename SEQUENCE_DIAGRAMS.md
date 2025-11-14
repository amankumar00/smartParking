# Smart Parking System - Sequence Diagrams (Corrected)

This document shows the **corrected sequence diagrams** for the Smart Parking Backend system based on the actual implementation.

---

## Table of Contents
1. [Vehicle Entry Flow](#vehicle-entry-flow)
2. [Vehicle Exit Flow](#vehicle-exit-flow)
3. [Key Differences from Original Diagrams](#key-differences-from-original-diagrams)
4. [Implementation References](#implementation-references)

---

## Vehicle Entry Flow

### Corrected Sequence Diagram

```
Sequence: Smart Parking - Vehicle Entry
══════════════════════════════════════════════════════════════════════════════

Actor: OCR/Client (Frontend/Mobile App)
System Lifelines:
  - Parking Controller
  - Parking Service
  - Vehicle Repository
  - Parking Slot Repository
  - Floor (Entity)


OCR/Client → Parking Controller :
    POST /api/parking/entry
    {
        "vehicleType": "FOUR_WHEELER",
        "vehicleRegistration": "KA01AB1234"
    }

Parking Controller → Parking Service :
    parkVehicle(VehicleEntryRequest)

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 1: Check if vehicle is already parked (prevent double parking)      ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Vehicle Repository :
    findByVehicleRegistrationAndStatus(
        "KA01AB1234",
        VehicleStatus.PARKED
    )

Vehicle Repository → Parking Service :
    Optional<Vehicle> (empty if not parked)

[If vehicle is ALREADY PARKED]
    Parking Service --X Parking Controller :
        throw InvalidOperationException(
            "Vehicle KA01AB1234 is already parked"
        )

    Parking Controller --X OCR/Client :
        400 BAD REQUEST
        {
            "status": "error",
            "message": "Vehicle KA01AB1234 is already parked"
        }
    (TERMINATE FLOW)
[End If]

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 2: Map vehicle type to slot type                                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Service :
    slotType = mapVehicleTypeToSlotType(FOUR_WHEELER)
    // Returns SlotType.FOUR_WHEELER

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 3: Find available parking slot                                      ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Slot Repository :
    findFirstBySlotTypeAndSlotStatus(
        SlotType.FOUR_WHEELER,
        SlotStatus.AVAILABLE
    )

Parking Slot Repository → Parking Service :
    Optional<ParkingSlot>

[If NO SLOT AVAILABLE]
    Parking Service --X Parking Controller :
        throw NoAvailableSlotException(
            "No available slot for FOUR_WHEELER"
        )

    Parking Controller --X OCR/Client :
        404 NOT FOUND
        {
            "status": "error",
            "message": "No available slot for FOUR_WHEELER"
        }
    (TERMINATE FLOW)
[End If]

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 4: Create new vehicle record                                        ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Service :
    vehicle = Vehicle.builder()
        .vehicleType(FOUR_WHEELER)
        .vehicleRegistration("KA01AB1234")
        .timeIn(LocalDateTime.now())
        .status(VehicleStatus.PARKED)
        .assignedSlot(availableSlot)
        .build()

Parking Service → Vehicle Repository :
    save(vehicle)

Vehicle Repository → Parking Service :
    savedVehicle (with generated vehicleId)

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 5: Update parking slot status                                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Slot Repository :
    availableSlot.setSlotStatus(SlotStatus.OCCUPIED)
    availableSlot.setCurrentVehicle(vehicle)
    save(availableSlot)

Parking Slot Repository → Parking Service :
    updatedSlot

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 6: Update floor occupancy counter                                   ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Floor :
    availableSlot.getFloor().incrementAllottedSlots()

Floor → Parking Service :
    (floor.allottedSlots++)

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 7: Return success response                                          ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Controller :
    VehicleResponse {
        vehicleId: "VEH-001",
        vehicleType: "FOUR_WHEELER",
        vehicleRegistration: "KA01AB1234",
        timeIn: "2025-11-14T10:30:00",
        status: "PARKED",
        assignedSlotId: "SLOT-F1-001"
    }

Parking Controller → OCR/Client :
    201 CREATED
    {
        "status": "success",
        "message": "Vehicle parked successfully",
        "data": {
            "vehicleId": "VEH-001",
            "vehicleType": "FOUR_WHEELER",
            "vehicleRegistration": "KA01AB1234",
            "timeIn": "2025-11-14T10:30:00",
            "timeOut": null,
            "status": "PARKED",
            "billAmt": null,
            "assignedSlotId": "SLOT-F1-001"
        }
    }

══════════════════════════════════════════════════════════════════════════════
```

### Key Points - Entry Flow

1. **No Classification Service**: The `vehicleType` must be provided in the request. The OCR/frontend is responsible for vehicle classification.

2. **No Vehicle Record Reuse**: Every parking creates a **new** `Vehicle` entity. The system doesn't reuse previous vehicle records.

3. **Double Parking Prevention**: Checks if the vehicle is **currently parked** (not if it exists in the database).

4. **Atomic Operations**: All database operations happen in a single `@Transactional` method.

5. **Bidirectional Relationship**: Both `Vehicle → ParkingSlot` and `ParkingSlot → Vehicle` are updated.

6. **Floor Counter**: The floor's `allottedSlots` counter is incremented to track occupancy.

### Implementation Reference - Entry

| Step | File | Lines |
|------|------|-------|
| Controller endpoint | [ParkingController.java](src/main/java/com/smartparking/controller/ParkingController.java) | 20-27 |
| Main service method | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 33-74 |
| Check already parked | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 37-43 |
| Find available slot | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 49-52 |
| Create vehicle | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 55-63 |
| Update slot | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 66-68 |
| Increment floor counter | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 71 |

---

## Vehicle Exit Flow

### Corrected Sequence Diagram

```
Sequence: Smart Parking - Vehicle Exit
══════════════════════════════════════════════════════════════════════════════

Actor: OCR/Client (Frontend/Mobile App)
System Lifelines:
  - Parking Controller
  - Parking Service
  - Vehicle Repository
  - Pricing Strategy
  - Parking Slot Repository
  - Floor (Entity)


OCR/Client → Parking Controller :
    POST /api/parking/exit/KA01AB1234

Parking Controller → Parking Service :
    exitVehicle("KA01AB1234")

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 1: Find parked vehicle                                              ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Vehicle Repository :
    findByVehicleRegistrationAndStatus(
        "KA01AB1234",
        VehicleStatus.PARKED
    )

Vehicle Repository → Parking Service :
    Optional<Vehicle>

[If NOT FOUND]
    Parking Service --X Parking Controller :
        throw ResourceNotFoundException(
            "No parked vehicle found with registration: KA01AB1234"
        )

    Parking Controller --X OCR/Client :
        404 NOT FOUND
        {
            "status": "error",
            "message": "No parked vehicle found with registration: KA01AB1234"
        }
    (TERMINATE FLOW)
[End If]

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 2: Calculate parking duration and bill amount                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Service :
    timeOut = LocalDateTime.now()
    // Example: vehicle.timeIn = 2025-11-14T10:30:00
    //          timeOut = 2025-11-14T13:45:00
    duration = Duration.between(vehicle.timeIn, timeOut)
    // Result: 3 hours 15 minutes

Parking Service → Pricing Strategy :
    calculatePrice(
        vehicleType = FOUR_WHEELER,
        parkingDuration = 3h 15m
    )

Pricing Strategy → Pricing Strategy :
    // DefaultPricingStrategy logic:
    // hours = 195 minutes / 60 = 3.25
    // baseRate = 20.0 (FOUR_WHEELER rate)
    // totalPrice = 20.0 * Math.ceil(3.25)
    //            = 20.0 * 4
    //            = 80.0

Pricing Strategy → Parking Service :
    billAmount = 80.0

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 3: Update vehicle record (all fields in single operation)           ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Service :
    vehicle.setTimeOut(timeOut)
    vehicle.setStatus(VehicleStatus.EXITED)
    vehicle.setBillAmt(80.0)

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 4: Release parking slot                                             ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Service :
    slot = vehicle.getAssignedSlot()

[If slot exists]
    Parking Service → Parking Slot Repository :
        slot.setSlotStatus(SlotStatus.AVAILABLE)
        slot.setCurrentVehicle(null)
        save(slot)

    Parking Slot Repository → Parking Service :
        updatedSlot

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 5: Update floor occupancy counter                                   ║
╚═══════════════════════════════════════════════════════════════════════════╝

    Parking Service → Floor :
        slot.getFloor().decrementAllottedSlots()

    Floor → Parking Service :
        (floor.allottedSlots--)
[End If]

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 6: Save updated vehicle record                                      ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Vehicle Repository :
    save(vehicle)

Vehicle Repository → Parking Service :
    savedVehicle

╔═══════════════════════════════════════════════════════════════════════════╗
║ STEP 7: Return success response with bill                                ║
╚═══════════════════════════════════════════════════════════════════════════╝

Parking Service → Parking Controller :
    VehicleResponse {
        vehicleId: "VEH-001",
        vehicleType: "FOUR_WHEELER",
        vehicleRegistration: "KA01AB1234",
        timeIn: "2025-11-14T10:30:00",
        timeOut: "2025-11-14T13:45:00",
        status: "EXITED",
        billAmt: 80.0,
        assignedSlotId: "SLOT-F1-001"
    }

Parking Controller → OCR/Client :
    200 OK
    {
        "status": "success",
        "message": "Vehicle exited successfully. Bill generated.",
        "data": {
            "vehicleId": "VEH-001",
            "vehicleType": "FOUR_WHEELER",
            "vehicleRegistration": "KA01AB1234",
            "timeIn": "2025-11-14T10:30:00",
            "timeOut": "2025-11-14T13:45:00",
            "status": "EXITED",
            "billAmt": 80.0,
            "assignedSlotId": "SLOT-F1-001"
        }
    }

══════════════════════════════════════════════════════════════════════════════
```

### Key Points - Exit Flow

1. **Single Transaction**: All updates (timeOut, status, billAmt) happen in one atomic operation.

2. **Pricing Strategy Pattern**: Uses `DefaultPricingStrategy` implementation that rounds up to the nearest hour.

3. **No Printer Service**: Returns bill information in HTTP JSON response.

4. **Floor Counter Decrement**: The floor's `allottedSlots` is decremented when slot is released.

5. **Null-Safe Slot Handling**: Checks if assigned slot exists before releasing.

6. **Single Save Operation**: Vehicle is saved once at the end with all fields updated.

### Pricing Details

The `DefaultPricingStrategy` implements the following rates:

| Vehicle Type | Base Rate | Minimum Charge |
|--------------|-----------|----------------|
| TWO_WHEELER | ₹10/hour | ₹5 (< 30 mins) |
| FOUR_WHEELER | ₹20/hour | ₹5 (< 30 mins) |
| HEAVY_VEHICLE | ₹40/hour | ₹5 (< 30 mins) |

**Calculation Logic:**
```java
// Round minutes to hours
double hours = parkingDuration.toMinutes() / 60.0;

// Minimum charge for < 30 minutes
if (hours < 0.5) return 5.0;

// Calculate price (rounded up to nearest hour)
double totalPrice = baseRate * Math.ceil(hours);
```

**Examples:**
- 25 minutes: ₹5 (minimum charge)
- 45 minutes: ₹10/₹20/₹40 (1 hour charge)
- 3 hours 15 minutes: ₹40/₹80/₹160 (4 hours charge - rounded up)

### Implementation Reference - Exit

| Step | File | Lines |
|------|------|-------|
| Controller endpoint | [ParkingController.java](src/main/java/com/smartparking/controller/ParkingController.java) | 29-34 |
| Main service method | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 76-109 |
| Find parked vehicle | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 80-83 |
| Calculate duration | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 86-87 |
| Calculate bill | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 88 |
| Update vehicle | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 91-93 |
| Release slot | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 96-100 |
| Decrement floor counter | [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java) | 103 |
| Pricing strategy interface | [PricingStrategy.java](src/main/java/com/smartparking/service/strategy/PricingStrategy.java) | 7-9 |
| Pricing implementation | [DefaultPricingStrategy.java](src/main/java/com/smartparking/service/strategy/DefaultPricingStrategy.java) | 9-36 |

---

## Key Differences from Original Diagrams

### ❌ Issues in Your Original Entry Diagram

| Your Diagram | Actual Implementation | Why Different |
|--------------|----------------------|---------------|
| **Classification Service** resolves vehicleType | `vehicleType` is **required in request** | No ML/image classification - OCR must provide type |
| `findByRegistration()` to check if record exists | `findByVehicleRegistrationAndStatus(reg, PARKED)` | Only prevents **double parking**, not duplicate records |
| **Reuses** existing vehicle record if found | **Always creates new** Vehicle entity | Each parking session = new record for history |
| **Slot Allocator Service** | `ParkingSlotRepository` with JPA query | No separate service - repository pattern |
| **Printer/Display Service** prints slip | Returns **JSON response** via HTTP | RESTful API - no physical printer integration |

### ❌ Issues in Your Original Exit Diagram

| Your Diagram | Actual Implementation | Why Different |
|--------------|----------------------|---------------|
| Separate `markTimeOut()` call | Part of single update operation | All fields updated together for atomicity |
| Then separate `updateStatus()` call | Same single operation | Prevents partial updates |
| **Printer/Display Service** prints bill | Returns **JSON response** with bill | RESTful API - client handles display |
| **Pricing Service** | `PricingStrategy` interface + implementation | Strategy pattern for flexibility |
| Save after timeOut, then save after status | **Single save** at end | Efficiency + transaction integrity |
| Missing floor decrement | `floor.decrementAllottedSlots()` exists | Critical for occupancy tracking |

### ✅ What You Got Right

**Entry Flow:**
- ✅ Entry point via OCR/external system
- ✅ NO_SLOT exception handling
- ✅ Slot assignment and status update
- ✅ Overall orchestration pattern

**Exit Flow:**
- ✅ Find vehicle by registration with PARKED status
- ✅ Pricing calculation based on duration
- ✅ Slot release mechanism
- ✅ ResourceNotFoundException for not found vehicles

---

## Implementation References

### Entity Relationships

```
ParkingLot (1) ◆──→ (*) Floor (1) ◆──→ (*) ParkingSlot
                                              ↕ (1:0..1)
                                           Vehicle
```

**Composition (◆):**
- `ParkingLot` → `Floor`: `@OneToMany(cascade = ALL, orphanRemoval = true)`
- `Floor` → `ParkingSlot`: `@OneToMany(cascade = ALL, orphanRemoval = true)`

**Association (↔):**
- `ParkingSlot` ↔ `Vehicle`: `@OneToOne` bidirectional

### Key Enums

**VehicleType:**
```java
TWO_WHEELER, FOUR_WHEELER, HEAVY_VEHICLE
```

**VehicleStatus:**
```java
PARKED, EXITED
```

**SlotType:**
```java
TWO_WHEELER, FOUR_WHEELER, HEAVY_VEHICLE
```

**SlotStatus:**
```java
AVAILABLE, OCCUPIED, UNDER_MAINTENANCE
```

### Exception Handling

All exceptions are handled by `GlobalExceptionHandler` using `@ControllerAdvice`:

| Exception | HTTP Status | When Thrown |
|-----------|-------------|-------------|
| `InvalidOperationException` | 400 BAD REQUEST | Vehicle already parked |
| `NoAvailableSlotException` | 404 NOT FOUND | No slots available for vehicle type |
| `ResourceNotFoundException` | 404 NOT FOUND | Vehicle/Slot/Floor not found |
| `MethodArgumentNotValidException` | 400 BAD REQUEST | Request validation failed |

### Transaction Management

Both `parkVehicle()` and `exitVehicle()` use `@Transactional`:

```java
@Override
@Transactional
public VehicleResponse parkVehicle(VehicleEntryRequest request) {
    // All database operations in single transaction
    // Rollback on any exception
}
```

**Benefits:**
- ✅ Atomicity: All-or-nothing updates
- ✅ Consistency: Data integrity maintained
- ✅ Isolation: Prevents concurrent modification issues
- ✅ Durability: Changes persisted reliably

---

## API Endpoints Summary

### Entry Endpoint
```http
POST /api/parking/entry
Content-Type: application/json

{
    "vehicleType": "FOUR_WHEELER",
    "vehicleRegistration": "KA01AB1234"
}
```

**Success Response (201 CREATED):**
```json
{
    "status": "success",
    "message": "Vehicle parked successfully",
    "data": {
        "vehicleId": "VEH-001",
        "vehicleType": "FOUR_WHEELER",
        "vehicleRegistration": "KA01AB1234",
        "timeIn": "2025-11-14T10:30:00",
        "timeOut": null,
        "status": "PARKED",
        "billAmt": null,
        "assignedSlotId": "SLOT-F1-001"
    }
}
```

### Exit Endpoint
```http
POST /api/parking/exit/KA01AB1234
```

**Success Response (200 OK):**
```json
{
    "status": "success",
    "message": "Vehicle exited successfully. Bill generated.",
    "data": {
        "vehicleId": "VEH-001",
        "vehicleType": "FOUR_WHEELER",
        "vehicleRegistration": "KA01AB1234",
        "timeIn": "2025-11-14T10:30:00",
        "timeOut": "2025-11-14T13:45:00",
        "status": "EXITED",
        "billAmt": 80.0,
        "assignedSlotId": "SLOT-F1-001"
    }
}
```

---

## Design Patterns Used

### 1. **Strategy Pattern** (Pricing)
- **Interface:** `PricingStrategy`
- **Implementation:** `DefaultPricingStrategy`
- **Benefit:** Easy to add new pricing strategies (hourly, daily, monthly, etc.)

### 2. **Repository Pattern** (Data Access)
- **Interfaces:** `VehicleRepository`, `ParkingSlotRepository`, etc.
- **Spring Data JPA:** Auto-implements CRUD + custom queries
- **Benefit:** Abstraction over database operations

### 3. **Facade Pattern** (Service Layer)
- **ParkingServiceImpl** hides complexity of:
  - Vehicle validation
  - Slot allocation
  - Price calculation
  - Database updates
- **Benefit:** Simple API for controllers

### 4. **Builder Pattern** (Entity Creation)
- **Lombok @Builder** on all entities
- **Example:** `Vehicle.builder().vehicleType(...).build()`
- **Benefit:** Readable, immutable object creation

### 5. **Exception Handler Pattern** (Error Handling)
- **GlobalExceptionHandler** with `@ControllerAdvice`
- Centralized exception → HTTP response mapping
- **Benefit:** Consistent error responses across API

---

## Testing the Flows

### Test Entry Flow (Using curl)
```bash
# Park a FOUR_WHEELER
curl -X POST http://localhost:8080/api/parking/entry \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleType": "FOUR_WHEELER",
    "vehicleRegistration": "KA01AB1234"
  }'

# Expected: 201 CREATED with assigned slot
```

### Test Exit Flow (Using curl)
```bash
# Exit the vehicle (wait a few seconds after parking)
curl -X POST http://localhost:8080/api/parking/exit/KA01AB1234

# Expected: 200 OK with bill amount
```

### Verify in H2 Console
```sql
-- View all vehicles
SELECT * FROM vehicles;

-- View slot occupancy
SELECT * FROM parking_slots WHERE slot_status = 'OCCUPIED';

-- View floor occupancy
SELECT floor_id, floor_number, total_slots, allotted_slots
FROM floors;
```

---

## Conclusion

The corrected sequence diagrams show:

1. **No classification/printer services** - these don't exist in the implementation
2. **No vehicle record reuse** - each parking creates a new record
3. **Single atomic transactions** - all updates happen together
4. **Proper exception handling** - with specific HTTP status codes
5. **Floor occupancy tracking** - incremented/decremented on entry/exit
6. **Strategy pattern for pricing** - flexible and extensible
7. **RESTful JSON responses** - no physical hardware integration

These diagrams accurately reflect your actual Spring Boot implementation as of the latest codebase analysis.
