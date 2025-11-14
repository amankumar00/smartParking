# ACTUAL CLASS STRUCTURE - SMART PARKING BACKEND

This document shows **EXACTLY** what exists in your codebase - fields, methods, relationships, and enums.

---

## 🔍 WHAT YOU ASKED ABOUT

You mentioned I said these weren't correct in your class diagram:
1. ❌ Methods like `getAvailableSlot()` and `generateSlip()` don't exist
2. ❌ `ParkingService` doesn't have `parkingLot: int` or `pricing: double` fields
3. ❌ `VehicleType` enum should not have `SUV`

Let me show you **EXACTLY** what's actually implemented.

---

## 📦 ENTITIES (Complete with ALL Fields)

### 1. Vehicle Entity

**File:** [Vehicle.java](src/main/java/com/smartparking/entity/Vehicle.java)

```java
@Entity
@Table(name = "vehicles")
public class Vehicle {

    // ✅ ACTUAL FIELDS:
    private String vehicleId;              // Primary Key (UUID)
    private VehicleType vehicleType;       // Enum: TWO_WHEELER, FOUR_WHEELER, HEAVY_VEHICLE
    private String vehicleRegistration;    // Vehicle plate number
    private LocalDateTime timeIn;          // Entry timestamp
    private LocalDateTime timeOut;         // Exit timestamp (nullable)
    private VehicleStatus status;          // Enum: PARKED, EXITED, IN_PROCESS
    private Double billAmt;                // Bill amount (nullable until exit)

    // ✅ ACTUAL RELATIONSHIP:
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_slot_id")
    private ParkingSlot assignedSlot;      // Reference to assigned parking slot

    // ✅ ACTUAL METHODS (from Lombok @Data):
    // - Getters: getVehicleId(), getVehicleType(), getVehicleRegistration(), etc.
    // - Setters: setVehicleId(), setVehicleType(), setVehicleRegistration(), etc.
    // - equals(), hashCode(), toString()

    // ✅ ACTUAL LIFECYCLE CALLBACK:
    @PrePersist
    protected void onCreate() {
        if (timeIn == null) timeIn = LocalDateTime.now();
        if (status == null) status = VehicleStatus.IN_PROCESS;
    }
}
```

**❌ What DOES NOT exist in Vehicle:**
- ❌ No `getAvailableSlot()` method
- ❌ No `generateSlip()` method
- ❌ No `calculateBill()` method
- ❌ No business logic methods (Entities are POJOs - Plain Old Java Objects)

---

### 2. ParkingSlot Entity

**File:** [ParkingSlot.java](src/main/java/com/smartparking/entity/ParkingSlot.java)

```java
@Entity
@Table(name = "parking_slots")
public class ParkingSlot {

    // ✅ ACTUAL FIELDS:
    private String slotId;                 // Primary Key (UUID)
    private SlotStatus slotStatus;         // Enum: AVAILABLE, OCCUPIED, UNDER_MAINTENANCE
    private SlotType slotType;             // Enum: TWO_WHEELER, FOUR_WHEELER, HEAVY_VEHICLE

    // ✅ ACTUAL RELATIONSHIPS:
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "floor_id", nullable = false)
    private Floor floor;                   // Belongs to one Floor

    @OneToOne(mappedBy = "assignedSlot", cascade = CascadeType.ALL)
    private Vehicle currentVehicle;        // Currently parked vehicle (nullable)

    // ✅ ACTUAL METHODS (from Lombok @Data):
    // - Standard getters/setters
    // - equals(), hashCode(), toString()
}
```

**❌ What DOES NOT exist in ParkingSlot:**
- ❌ No `isAvailable()` method (status is checked via `slotStatus` field)
- ❌ No `assignVehicle()` method (done by service layer)
- ❌ No business logic

---

### 3. Floor Entity

**File:** [Floor.java](src/main/java/com/smartparking/entity/Floor.java)

```java
@Entity
@Table(name = "floors")
public class Floor {

    // ✅ ACTUAL FIELDS:
    private String floorId;                // Primary Key (UUID)
    private Integer floorNo;               // Floor number (0, 1, 2, etc.)
    private Integer totalSlots;            // Total number of slots on this floor
    private Integer allottedSlots;         // Currently occupied slots

    // ✅ ACTUAL RELATIONSHIPS:
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parking_lot_id", nullable = false)
    private ParkingLot parkingLot;         // Belongs to one ParkingLot

    @OneToMany(mappedBy = "floor", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ParkingSlot> slots = new ArrayList<>();

    // ✅ ACTUAL METHODS (CUSTOM - not from Lombok):
    public void incrementAllottedSlots() {
        this.allottedSlots++;
    }

    public void decrementAllottedSlots() {
        if (this.allottedSlots > 0) {
            this.allottedSlots--;
        }
    }

    // + Standard getters/setters from @Data
}
```

**✅ What EXISTS in Floor:**
- ✅ `incrementAllottedSlots()` - Called when vehicle parks
- ✅ `decrementAllottedSlots()` - Called when vehicle exits

**❌ What DOES NOT exist in Floor:**
- ❌ No `getAvailableSlots()` method (calculated via repositories)
- ❌ No `findSlot()` method (done by repository layer)

---

### 4. ParkingLot Entity

**File:** [ParkingLot.java](src/main/java/com/smartparking/entity/ParkingLot.java)

```java
@Entity
@Table(name = "parking_lots")
public class ParkingLot {

    // ✅ ACTUAL FIELDS:
    private String parkingLotId;           // Primary Key (UUID)
    private String name;                   // Parking lot name
    private String address;                // Address (max 500 chars)
    private Integer totalFloors;           // Total number of floors
    private LocalDateTime createdAt;       // Creation timestamp
    private LocalDateTime updatedAt;       // Last update timestamp

    // ✅ ACTUAL RELATIONSHIP:
    @OneToMany(mappedBy = "parkingLot", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Floor> floors = new ArrayList<>();

    // ✅ ACTUAL LIFECYCLE CALLBACKS:
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // + Standard getters/setters from @Data
}
```

**❌ What DOES NOT exist in ParkingLot:**
- ❌ No `calculateOccupancy()` method
- ❌ No `addFloor()` method (done via cascade)

---

## 🔧 SERVICE LAYER (Interfaces and Methods)

### ParkingService Interface

**File:** [ParkingService.java](src/main/java/com/smartparking/service/ParkingService.java)

```java
public interface ParkingService {

    // ✅ ACTUAL METHODS (ONLY 3):
    VehicleResponse parkVehicle(VehicleEntryRequest request);
    VehicleResponse exitVehicle(String vehicleRegistration);
    VehicleResponse getVehicleByRegistration(String vehicleRegistration);
}
```

**✅ What EXISTS:**
- ✅ `parkVehicle()` - Parks a vehicle and assigns slot
- ✅ `exitVehicle()` - Exits vehicle and generates bill
- ✅ `getVehicleByRegistration()` - Retrieves vehicle info

**❌ What DOES NOT exist:**
- ❌ **NO** `getAvailableSlot()` method
- ❌ **NO** `generateSlip()` method
- ❌ **NO** `calculateBill()` method (done internally in `exitVehicle()`)
- ❌ **NO** `assignSlot()` method (done internally in `parkVehicle()`)

---

### ParkingServiceImpl (Implementation)

**File:** [ParkingServiceImpl.java](src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java)

```java
@Service
public class ParkingServiceImpl implements ParkingService {

    // ✅ ACTUAL DEPENDENCIES (NOT fields in interface):
    private final VehicleRepository vehicleRepository;
    private final ParkingSlotRepository parkingSlotRepository;
    private final PricingStrategy pricingStrategy;

    // ✅ ACTUAL PUBLIC METHODS (from interface):
    @Transactional
    public VehicleResponse parkVehicle(VehicleEntryRequest request) {
        // Implementation:
        // 1. Check if already parked
        // 2. Find available slot
        // 3. Check if vehicle has exited before (NEW - reuse record)
        // 4. Create/reuse vehicle entity
        // 5. Update slot status
        // 6. Increment floor counter
        // 7. Return response
    }

    @Transactional
    public VehicleResponse exitVehicle(String vehicleRegistration) {
        // Implementation:
        // 1. Find parked vehicle
        // 2. Calculate duration and bill
        // 3. Update vehicle (timeOut, status, billAmt)
        // 4. Release slot
        // 5. Decrement floor counter
        // 6. Return response
    }

    public VehicleResponse getVehicleByRegistration(String vehicleRegistration) {
        // Implementation: Find and return vehicle
    }

    // ✅ ACTUAL PRIVATE HELPER METHODS:
    private SlotType mapVehicleTypeToSlotType(VehicleType vehicleType) {
        // Maps VehicleType enum to SlotType enum
    }

    private VehicleResponse mapToResponse(Vehicle vehicle) {
        // Converts Vehicle entity to VehicleResponse DTO
    }
}
```

**❌ What your diagram might show but DOESN'T exist:**
- ❌ **NO** `parkingLot: int` field in ParkingService
- ❌ **NO** `pricing: double` field in ParkingService
- ❌ These are NOT stored as fields - they are dependencies injected via constructor

---

## 🎨 ENUMS (Exact Values)

### VehicleType Enum

**File:** [VehicleType.java](src/main/java/com/smartparking/enums/VehicleType.java)

```java
public enum VehicleType {
    TWO_WHEELER,    // ✅ Motorcycles, scooters
    FOUR_WHEELER,   // ✅ Cars, SUVs (SUV is NOT a separate enum value!)
    HEAVY_VEHICLE   // ✅ Trucks, buses
}
```

**❌ Your diagram might show:**
```java
// ❌ WRONG - SUV is NOT a separate value:
public enum VehicleType {
    TWO_WHEELER,
    FOUR_WHEELER,
    SUV,            // ❌ DOES NOT EXIST
    HEAVY_VEHICLE
}
```

**✅ CORRECT: SUVs are categorized as FOUR_WHEELER**

---

### VehicleStatus Enum

**File:** [VehicleStatus.java](src/main/java/com/smartparking/enums/VehicleStatus.java)

```java
public enum VehicleStatus {
    IN_PROCESS,     // ✅ Default status (set by @PrePersist)
    PARKED,         // ✅ Currently parked
    EXITED          // ✅ Has exited
}
```

---

### SlotType Enum

**File:** [SlotType.java](src/main/java/com/smartparking/enums/SlotType.java)

```java
public enum SlotType {
    TWO_WHEELER,    // ✅ For motorcycles
    FOUR_WHEELER,   // ✅ For cars/SUVs
    HEAVY_VEHICLE   // ✅ For trucks/buses
}
```

**Note:** `SlotType` mirrors `VehicleType` (both have same 3 values)

---

### SlotStatus Enum

**File:** [SlotStatus.java](src/main/java/com/smartparking/enums/SlotStatus.java)

```java
public enum SlotStatus {
    AVAILABLE,          // ✅ Ready for parking
    OCCUPIED,           // ✅ Currently in use
    UNDER_MAINTENANCE   // ✅ Not available
}
```

---

## 🎯 STRATEGY PATTERN (Pricing)

### PricingStrategy Interface

**File:** [PricingStrategy.java](src/main/java/com/smartparking/service/strategy/PricingStrategy.java)

```java
public interface PricingStrategy {

    // ✅ ACTUAL METHOD:
    double calculatePrice(VehicleType vehicleType, Duration parkingDuration);
}
```

**✅ What EXISTS:**
- ✅ `calculatePrice()` - Takes vehicleType and duration, returns price

**❌ What DOES NOT exist:**
- ❌ **NO** `getRate()` method
- ❌ **NO** `setRate()` method (rates are constants in implementation)

---

### DefaultPricingStrategy Implementation

**File:** [DefaultPricingStrategy.java](src/main/java/com/smartparking/service/strategy/DefaultPricingStrategy.java)

```java
@Component
public class DefaultPricingStrategy implements PricingStrategy {

    // ✅ ACTUAL CONSTANTS (NOT configurable fields):
    private static final double TWO_WHEELER_BASE_RATE = 10.0;
    private static final double FOUR_WHEELER_BASE_RATE = 20.0;
    private static final double HEAVY_VEHICLE_BASE_RATE = 40.0;
    private static final double MINIMUM_CHARGE = 5.0;

    // ✅ ACTUAL METHOD:
    @Override
    public double calculatePrice(VehicleType vehicleType, Duration parkingDuration) {
        double hours = parkingDuration.toMinutes() / 60.0;

        if (hours < 0.5) {
            return MINIMUM_CHARGE;
        }

        double baseRate = switch (vehicleType) {
            case TWO_WHEELER -> TWO_WHEELER_BASE_RATE;
            case FOUR_WHEELER -> FOUR_WHEELER_BASE_RATE;
            case HEAVY_VEHICLE -> HEAVY_VEHICLE_BASE_RATE;
        };

        double totalPrice = baseRate * Math.ceil(hours);
        return Math.round(totalPrice * 100.0) / 100.0;
    }
}
```

**❌ What your diagram might show but DOESN'T exist:**
- ❌ **NO** `rates: Map<VehicleType, Double>` field
- ❌ **NO** `setRate()` method
- ❌ Rates are **hardcoded constants**, not configurable

---

## 🔗 RELATIONSHIPS (Entity Relationships)

### Complete Relationship Diagram

```
ParkingLot
    └── floors: List<Floor>                     [1:*] @OneToMany, CASCADE ALL

Floor
    ├── parkingLot: ParkingLot                 [*:1] @ManyToOne
    └── slots: List<ParkingSlot>               [1:*] @OneToMany, CASCADE ALL

ParkingSlot
    ├── floor: Floor                           [*:1] @ManyToOne
    └── currentVehicle: Vehicle                [1:0..1] @OneToOne (mappedBy)

Vehicle
    └── assignedSlot: ParkingSlot              [1:0..1] @OneToOne
```

**Key Points:**
- ✅ **Composition** (◆): ParkingLot → Floor → ParkingSlot (CASCADE ALL, orphanRemoval)
- ✅ **Association** (──): ParkingSlot ↔ Vehicle (Bidirectional @OneToOne)
- ✅ **Multiplicity**: 1:*, *:1, 1:0..1

---

## 📋 CORRECTED CLASS DIAGRAM STRUCTURE

Here's what **ACTUALLY** should be in your class diagram:

### Class: ParkingService (Interface)

```
┌─────────────────────────────────┐
│      <<interface>>              │
│      ParkingService             │
├─────────────────────────────────┤
│ (No fields)                     │
├─────────────────────────────────┤
│ + parkVehicle(request)          │
│ + exitVehicle(registration)     │
│ + getVehicleByRegistration(reg) │
└─────────────────────────────────┘
```

**❌ DO NOT include:**
- ❌ `parkingLot: int`
- ❌ `pricing: double`
- ❌ `getAvailableSlot()`
- ❌ `generateSlip()`

---

### Class: ParkingServiceImpl (Implementation)

```
┌─────────────────────────────────────────┐
│      ParkingServiceImpl                 │
├─────────────────────────────────────────┤
│ - vehicleRepository: VehicleRepository  │
│ - parkingSlotRepository: ParkingSlot... │
│ - pricingStrategy: PricingStrategy      │
├─────────────────────────────────────────┤
│ + parkVehicle(request): VehicleResponse │
│ + exitVehicle(reg): VehicleResponse     │
│ + getVehicleByRegistration(reg): ...    │
│ - mapVehicleTypeToSlotType(type): ...   │
│ - mapToResponse(vehicle): ...           │
└─────────────────────────────────────────┘
```

---

### Class: Vehicle (Entity)

```
┌───────────────────────────────────┐
│          Vehicle                  │
├───────────────────────────────────┤
│ - vehicleId: String               │
│ - vehicleType: VehicleType        │
│ - vehicleRegistration: String     │
│ - timeIn: LocalDateTime           │
│ - timeOut: LocalDateTime          │
│ - status: VehicleStatus           │
│ - billAmt: Double                 │
│ - assignedSlot: ParkingSlot       │
├───────────────────────────────────┤
│ + getters/setters (Lombok)        │
│ # onCreate(): void                │
└───────────────────────────────────┘
```

**❌ DO NOT include:**
- ❌ `getAvailableSlot()`
- ❌ `generateSlip()`
- ❌ `calculateBill()`

---

### Class: ParkingSlot (Entity)

```
┌───────────────────────────────────┐
│        ParkingSlot                │
├───────────────────────────────────┤
│ - slotId: String                  │
│ - slotStatus: SlotStatus          │
│ - slotType: SlotType              │
│ - floor: Floor                    │
│ - currentVehicle: Vehicle         │
├───────────────────────────────────┤
│ + getters/setters (Lombok)        │
└───────────────────────────────────┘
```

**❌ DO NOT include:**
- ❌ `isAvailable()`
- ❌ `assignVehicle()`

---

### Class: Floor (Entity)

```
┌───────────────────────────────────┐
│           Floor                   │
├───────────────────────────────────┤
│ - floorId: String                 │
│ - floorNo: Integer                │
│ - totalSlots: Integer             │
│ - allottedSlots: Integer          │
│ - parkingLot: ParkingLot          │
│ - slots: List<ParkingSlot>        │
├───────────────────────────────────┤
│ + getters/setters (Lombok)        │
│ + incrementAllottedSlots(): void  │
│ + decrementAllottedSlots(): void  │
└───────────────────────────────────┘
```

**✅ DO include:**
- ✅ `incrementAllottedSlots()` - This EXISTS
- ✅ `decrementAllottedSlots()` - This EXISTS

---

### Class: ParkingLot (Entity)

```
┌───────────────────────────────────┐
│        ParkingLot                 │
├───────────────────────────────────┤
│ - parkingLotId: String            │
│ - name: String                    │
│ - address: String                 │
│ - totalFloors: Integer            │
│ - floors: List<Floor>             │
│ - createdAt: LocalDateTime        │
│ - updatedAt: LocalDateTime        │
├───────────────────────────────────┤
│ + getters/setters (Lombok)        │
│ # onCreate(): void                │
│ # onUpdate(): void                │
└───────────────────────────────────┘
```

---

### Enum: VehicleType

```
┌───────────────────────┐
│   <<enumeration>>     │
│     VehicleType       │
├───────────────────────┤
│ TWO_WHEELER           │
│ FOUR_WHEELER          │
│ HEAVY_VEHICLE         │
└───────────────────────┘
```

**❌ DO NOT include:**
- ❌ `SUV` - This is NOT a separate enum value!

---

### Enum: VehicleStatus

```
┌───────────────────────┐
│   <<enumeration>>     │
│    VehicleStatus      │
├───────────────────────┤
│ IN_PROCESS            │
│ PARKED                │
│ EXITED                │
└───────────────────────┘
```

---

### Interface: PricingStrategy

```
┌─────────────────────────────────────┐
│        <<interface>>                │
│      PricingStrategy                │
├─────────────────────────────────────┤
│ (No fields)                         │
├─────────────────────────────────────┤
│ + calculatePrice(type, duration)    │
└─────────────────────────────────────┘
```

---

### Class: DefaultPricingStrategy

```
┌──────────────────────────────────────────┐
│     DefaultPricingStrategy               │
├──────────────────────────────────────────┤
│ - TWO_WHEELER_BASE_RATE: double = 10.0   │
│ - FOUR_WHEELER_BASE_RATE: double = 20.0  │
│ - HEAVY_VEHICLE_BASE_RATE: double = 40.0 │
│ - MINIMUM_CHARGE: double = 5.0           │
├──────────────────────────────────────────┤
│ + calculatePrice(type, duration): double │
└──────────────────────────────────────────┘
```

---

## 🔍 SUMMARY OF CORRECTIONS

### ❌ Methods That DO NOT Exist (Remove from your diagram):

| Class | Method | Why It Doesn't Exist |
|-------|--------|---------------------|
| `ParkingService` | `getAvailableSlot()` | Slot finding is done internally in `parkVehicle()` |
| `ParkingService` | `generateSlip()` | No slip generation - returns JSON response |
| `ParkingService` | `calculateBill()` | Bill calculation is done internally in `exitVehicle()` |
| `ParkingService` | `assignSlot()` | Slot assignment is done internally in `parkVehicle()` |
| `Vehicle` | `getAvailableSlot()` | Makes no sense - Vehicle doesn't find slots |
| `Vehicle` | `generateSlip()` | Business logic belongs in service layer |
| `Vehicle` | `calculateBill()` | Business logic belongs in service layer |
| `ParkingSlot` | `isAvailable()` | Status is checked via `slotStatus` field |
| `ParkingSlot` | `assignVehicle()` | Done by service layer, not entity |

---

### ❌ Fields That DO NOT Exist (Remove from your diagram):

| Class | Field | Why It Doesn't Exist |
|-------|-------|---------------------|
| `ParkingService` | `parkingLot: int` | Not stored - repositories handle data access |
| `ParkingService` | `pricing: double` | Not stored - `PricingStrategy` is injected dependency |
| `DefaultPricingStrategy` | `rates: Map<...>` | Rates are hardcoded constants, not configurable |

---

### ✅ Methods That DO Exist (Keep in your diagram):

| Class | Method | File Location |
|-------|--------|---------------|
| `ParkingService` | `parkVehicle(request)` | [ParkingService.java:7](src/main/java/com/smartparking/service/ParkingService.java#L7) |
| `ParkingService` | `exitVehicle(registration)` | [ParkingService.java:8](src/main/java/com/smartparking/service/ParkingService.java#L8) |
| `ParkingService` | `getVehicleByRegistration(reg)` | [ParkingService.java:9](src/main/java/com/smartparking/service/ParkingService.java#L9) |
| `Floor` | `incrementAllottedSlots()` | [Floor.java:42-44](src/main/java/com/smartparking/entity/Floor.java#L42-L44) |
| `Floor` | `decrementAllottedSlots()` | [Floor.java:46-50](src/main/java/com/smartparking/entity/Floor.java#L46-L50) |
| `PricingStrategy` | `calculatePrice(type, duration)` | [PricingStrategy.java:8](src/main/java/com/smartparking/service/strategy/PricingStrategy.java#L8) |

---

### ✅ Enums - Correct Values:

| Enum | Correct Values | File |
|------|---------------|------|
| `VehicleType` | `TWO_WHEELER`, `FOUR_WHEELER`, `HEAVY_VEHICLE` | [VehicleType.java](src/main/java/com/smartparking/enums/VehicleType.java) |
| `VehicleStatus` | `IN_PROCESS`, `PARKED`, `EXITED` | [VehicleStatus.java](src/main/java/com/smartparking/enums/VehicleStatus.java) |
| `SlotType` | `TWO_WHEELER`, `FOUR_WHEELER`, `HEAVY_VEHICLE` | [SlotType.java](src/main/java/com/smartparking/enums/SlotType.java) |
| `SlotStatus` | `AVAILABLE`, `OCCUPIED`, `UNDER_MAINTENANCE` | [SlotStatus.java](src/main/java/com/smartparking/enums/SlotStatus.java) |

---

## 🎯 FINAL CHECKLIST FOR YOUR CLASS DIAGRAM

Use this checklist to verify your diagram:

### Entity Classes:
- [ ] `Vehicle` has 8 fields: vehicleId, vehicleType, vehicleRegistration, timeIn, timeOut, status, billAmt, assignedSlot
- [ ] `ParkingSlot` has 5 fields: slotId, slotStatus, slotType, floor, currentVehicle
- [ ] `Floor` has 6 fields: floorId, floorNo, totalSlots, allottedSlots, parkingLot, slots
- [ ] `ParkingLot` has 7 fields: parkingLotId, name, address, totalFloors, floors, createdAt, updatedAt

### Service Interface:
- [ ] `ParkingService` has **NO fields**
- [ ] `ParkingService` has **ONLY 3 methods**: parkVehicle, exitVehicle, getVehicleByRegistration
- [ ] `ParkingService` does **NOT** have: getAvailableSlot, generateSlip, calculateBill, assignSlot

### Enums:
- [ ] `VehicleType` has **ONLY 3 values**: TWO_WHEELER, FOUR_WHEELER, HEAVY_VEHICLE
- [ ] `VehicleType` does **NOT** have: SUV (it's a FOUR_WHEELER!)

### Strategy Pattern:
- [ ] `PricingStrategy` interface with 1 method: calculatePrice
- [ ] `DefaultPricingStrategy` implements PricingStrategy
- [ ] Rates are **constants**, not configurable fields

### Relationships:
- [ ] ParkingLot ◆──→ Floor (Composition, 1:*)
- [ ] Floor ◆──→ ParkingSlot (Composition, 1:*)
- [ ] ParkingSlot ↔ Vehicle (Association, 1:0..1 bidirectional)

---

This document shows **EXACTLY** what's in your codebase. Use it to correct your class diagram!