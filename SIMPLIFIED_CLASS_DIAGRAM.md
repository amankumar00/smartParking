# SMART PARKING - SIMPLIFIED CLASS DIAGRAM

## 🎯 CORE CLASS DIAGRAM (Clean & Simple)

```
╔══════════════════════════════════════════════════════════════════╗
║                    ENTITY LAYER (Domain Model)                    ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────┐
│      ParkingLot         │
├─────────────────────────┤
│ - parkingLotId: String  │
│ - name: String          │
│ - address: String       │
│ - totalFloors: Integer  │
│ - createdAt: DateTime   │
│ - updatedAt: DateTime   │
└────────┬────────────────┘
         │
         │ 1         *  (Composition - Diamond)
         │◆───────────►  "owns"
         │
┌────────▼────────────────┐
│        Floor            │
├─────────────────────────┤
│ - floorId: String       │
│ - floorNo: Integer      │
│ - totalSlots: Integer   │
│ - allottedSlots: Integer│
└────────┬────────────────┘
         │
         │ 1         *  (Composition)
         │◆───────────►  "owns"
         │
┌────────▼────────────────┐
│     ParkingSlot         │
├─────────────────────────┤
│ - slotId: String        │
│ - slotStatus: enum      │
│ - slotType: enum        │
└────────┬────────────────┘
         │
         │ 1         1  (Association - Arrow)
         │────────────►  "assigned to"
         │
┌────────▼────────────────┐
│       Vehicle           │
├─────────────────────────┤
│ - vehicleId: String     │
│ - vehicleType: enum     │
│ - vehicleRegistration   │
│ - timeIn: DateTime      │
│ - timeOut: DateTime     │
│ - status: enum          │
│ - billAmt: Double       │
└─────────────────────────┘


┌─────────────────────────┐
│       Employee          │ (Standalone - No relationships)
├─────────────────────────┤
│ - empId: String         │
│ - name: String          │
│ - email: String         │
│ - phNo: String          │
│ - dob: Date             │
│ - gender: enum          │
│ - roles: String         │
└─────────────────────────┘


Legend:
───────
  1        *     One-to-Many
  ◆──────►       Composition (Strong ownership)
  ────────►      Association (Weak relationship)
```

---

## 🔷 MULTIPLICITY EXPLAINED

```
ParkingLot ─────── Floor
    1          *

One ParkingLot has Many Floors
(1:N relationship)


Floor ─────── ParkingSlot
  1        *

One Floor has Many ParkingSlots
(1:N relationship)


ParkingSlot ─────── Vehicle
     1          1

One ParkingSlot has One Vehicle
(1:1 relationship)
```

---

## 🔶 AGGREGATION vs COMPOSITION

```
COMPOSITION (Strong - Diamond ◆)
────────────────────────────────
When parent dies, children die

ParkingLot ◆────► Floor
    │
    └─ If ParkingLot is deleted,
       all Floors are deleted

Floor ◆────► ParkingSlot
    │
    └─ If Floor is deleted,
       all ParkingSlots are deleted


ASSOCIATION (Weak - Arrow ──►)
────────────────────────────────
Children can exist independently

ParkingSlot ────► Vehicle
    │
    └─ If ParkingSlot is deleted,
       Vehicle still exists
       (just unassigned)
```

---

## 📐 INHERITANCE HIERARCHY

```
╔══════════════════════════════════════════════════════════════════╗
║                    REPOSITORY LAYER                               ║
╚══════════════════════════════════════════════════════════════════╝

                    ┌──────────────────────────┐
                    │   <<interface>>          │
                    │   JpaRepository<T, ID>   │
                    │   (Spring Framework)     │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
                    │ extends    │ extends    │ extends
                    │            │            │
        ┌───────────▼───────┐   │   ┌────────▼────────┐
        │EmployeeRepository │   │   │VehicleRepository│
        │   <<interface>>   │   │   │  <<interface>>  │
        └───────────────────┘   │   └─────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │ParkingSlotRepository   │
                    │    <<interface>>       │
                    └────────────────────────┘

                    ┌───────────▼───────┐  ┌────────────▼──────┐
                    │FloorRepository    │  │ParkingLotRepository│
                    │  <<interface>>    │  │   <<interface>>    │
                    └───────────────────┘  └───────────────────┘

All repositories INHERIT from JpaRepository
(They get: save, findById, findAll, delete, etc.)
```

---

## 🔀 POLYMORPHISM

```
╔══════════════════════════════════════════════════════════════════╗
║                      SERVICE LAYER                                ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────┐
│    <<interface>>        │
│    ParkingService       │      Interface (Contract)
├─────────────────────────┤
│ + parkVehicle()         │
│ + exitVehicle()         │
│ + getVehicle()          │
└────────┬────────────────┘
         │
         │ implements (Triangle ▲)
         │
         ▲
         │
┌────────┴────────────────┐
│  ParkingServiceImpl     │      Implementation
├─────────────────────────┤
│ + parkVehicle()         │      Actual code here
│ + exitVehicle()         │
│ + getVehicle()          │
└─────────────────────────┘

Controller uses: ParkingService (interface)
Spring injects: ParkingServiceImpl (concrete class)
This is POLYMORPHISM - same interface, different implementation


Same pattern for:
├─ EmployeeService ▲ EmployeeServiceImpl
├─ ParkingLotService ▲ ParkingLotServiceImpl
└─ AuthService ▲ AuthServiceImpl
```

---

## 🎨 STRATEGY PATTERN

```
┌─────────────────────────┐
│    <<interface>>        │
│   PricingStrategy       │
├─────────────────────────┤
│ + calculatePrice()      │
└────────┬────────────────┘
         │
         │ implements
         ▲
         │
┌────────┴────────────────┐
│DefaultPricingStrategy   │
├─────────────────────────┤
│ + calculatePrice()      │
│   ├─ TWO_WHEELER: ₹10   │
│   ├─ FOUR_WHEELER: ₹20  │
│   └─ HEAVY_VEHICLE: ₹40 │
└─────────────────────────┘

Can add more strategies:
├─ WeekendPricingStrategy (50% off)
└─ PeakHourPricingStrategy (surge pricing)

ParkingServiceImpl uses PricingStrategy
(Can swap implementation without changing code)
```

---

## 📊 COMPLETE SIMPLIFIED DIAGRAM

```
┌─────────────────────────────────────────────────────────────────┐
│                   LAYERED ARCHITECTURE                           │
└─────────────────────────────────────────────────────────────────┘

LAYER 1: CONTROLLERS (REST API)
────────────────────────────────
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Parking    │  │   Employee   │  │  ParkingLot  │
│  Controller  │  │  Controller  │  │  Controller  │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       │ uses            │ uses            │ uses
       ▼                 ▼                 ▼

LAYER 2: SERVICES (Business Logic)
───────────────────────────────────
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│<<interface>> │  │<<interface>> │  │<<interface>> │
│   Parking    │  │   Employee   │  │  ParkingLot  │
│   Service    │  │   Service    │  │   Service    │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       │ implements      │ implements      │ implements
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Parking    │  │   Employee   │  │  ParkingLot  │
│ServiceImpl   │  │ServiceImpl   │  │ServiceImpl   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       │ uses            │ uses            │ uses
       ▼                 ▼                 ▼

LAYER 3: REPOSITORIES (Data Access)
────────────────────────────────────
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Vehicle    │  │   Employee   │  │  ParkingLot  │
│  Repository  │  │  Repository  │  │  Repository  │
│              │  │              │  │              │
│ extends      │  │ extends      │  │ extends      │
│JpaRepository │  │JpaRepository │  │JpaRepository │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       │ manages         │ manages         │ manages
       ▼                 ▼                 ▼

LAYER 4: ENTITIES (Domain Model)
─────────────────────────────────
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Vehicle    │  │   Employee   │  │  ParkingLot  │
│              │  │              │  │      │       │
│              │  │              │  │      ◆ owns  │
└──────────────┘  └──────────────┘  │      │       │
                                    │      ▼       │
                                    │   Floor      │
                                    │      │       │
                                    │      ◆ owns  │
                                    │      │       │
                                    │      ▼       │
                                    │ ParkingSlot  │
                                    │      │       │
                                    │      ───►    │
                                    │   Vehicle    │
                                    └──────────────┘
```

---

## 🔢 MULTIPLICITY SYMBOLS

```
Symbol    Meaning              Example
──────────────────────────────────────────────────
  1       Exactly one          Floor has 1 ParkingLot
  *       Zero or more         ParkingLot has * Floors
  0..1    Zero or one          ParkingSlot has 0..1 Vehicle
  1..*    One or more          Floor has 1..* ParkingSlots
  n       Specific number
```

---

## 🔗 RELATIONSHIP TYPES

```
Type            Symbol      Meaning
─────────────────────────────────────────────────────
Composition     ◆────►      Strong ownership
                            Parent dies → Children die

Association     ────►       Weak relationship
                            Objects independent

Inheritance     ────▲       IS-A relationship
                            Child extends Parent

Implementation  ----▲       Implements interface
 (dashed)                   Class → Interface

Dependency      ---->       Uses temporarily
 (dashed arrow)             Method parameter
```

---

## 📝 ENTITY RELATIONSHIPS (Simple View)

```
1. ParkingLot → Floor → ParkingSlot
   ─────────────────────────────────
   Composition chain:
   - Delete ParkingLot → Deletes all Floors → Deletes all Slots

   Multiplicity:
   - 1 ParkingLot : N Floors
   - 1 Floor : N ParkingSlots


2. ParkingSlot ⟷ Vehicle
   ────────────────────────
   Bidirectional association:
   - ParkingSlot knows its Vehicle
   - Vehicle knows its ParkingSlot

   Multiplicity:
   - 1 ParkingSlot : 0..1 Vehicle
   - 1 Vehicle : 0..1 ParkingSlot


3. Employee
   ─────────
   Standalone entity:
   - No relationships with other entities
   - Manages system users
```

---

## 🎯 KEY CONCEPTS (Ultra Simplified)

```
1. INHERITANCE
   ────────────
   All repositories extend JpaRepository

   JpaRepository
        ▲
        │ extends
        │
   VehicleRepository


2. POLYMORPHISM
   ─────────────
   Controller uses interface, Spring gives implementation

   ParkingService (interface)
        ▲
        │ implements
        │
   ParkingServiceImpl


3. COMPOSITION
   ────────────
   Parent owns children strongly

   ParkingLot ◆──► Floor ◆──► ParkingSlot


4. ASSOCIATION
   ────────────
   Objects related but independent

   ParkingSlot ───► Vehicle
```

---

## 📊 RELATIONSHIP SUMMARY

```
Relationship                     Type            Multiplicity
───────────────────────────────────────────────────────────────
ParkingLot → Floor               Composition     1 : *
Floor → ParkingSlot              Composition     1 : *
ParkingSlot ⟷ Vehicle           Association     1 : 0..1
Employee (standalone)            None            -

Repository → JpaRepository       Inheritance     N : 1
ServiceImpl → Service Interface  Polymorphism    1 : 1
Strategy → Interface             Polymorphism    1 : 1
```

---

## 🗂️ FILE LOCATIONS

```
Entities:
📁 /src/main/java/com/smartparking/entity/
   ├─ ParkingLot.java     (1 : * Floor)
   ├─ Floor.java          (1 : * ParkingSlot)
   ├─ ParkingSlot.java    (1 : 0..1 Vehicle)
   ├─ Vehicle.java
   └─ Employee.java

Repositories (Inheritance):
📁 /src/main/java/com/smartparking/repository/
   ├─ EmployeeRepository.java      (extends JpaRepository)
   ├─ VehicleRepository.java       (extends JpaRepository)
   ├─ ParkingSlotRepository.java   (extends JpaRepository)
   ├─ FloorRepository.java         (extends JpaRepository)
   └─ ParkingLotRepository.java    (extends JpaRepository)

Services (Polymorphism):
📁 /src/main/java/com/smartparking/service/
   ├─ ParkingService.java          (interface)
   ├─ EmployeeService.java         (interface)
   ├─ ParkingLotService.java       (interface)
   └─ AuthService.java             (interface)

Service Implementations:
📁 /src/main/java/com/smartparking/service/impl/
   ├─ ParkingServiceImpl.java      (implements ParkingService)
   ├─ EmployeeServiceImpl.java     (implements EmployeeService)
   ├─ ParkingLotServiceImpl.java   (implements ParkingLotService)
   └─ AuthServiceImpl.java         (implements AuthService)
```

---

## END OF SIMPLIFIED CLASS DIAGRAM