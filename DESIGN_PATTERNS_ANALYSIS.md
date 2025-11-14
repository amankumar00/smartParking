# DESIGN PATTERNS ANALYSIS - SMART PARKING BACKEND

## 📊 ABOUT YOUR CLASS DIAGRAM

**Your diagram is MOSTLY CORRECT** with minor adjustments needed:

### ✅ Correct Elements:
1. **PricingStrategy** interface with DefaultPricingStrategy implementation
2. **ParkingService** uses PricingStrategy
3. **Entity relationships**: ParkingLot → Floor → ParkingSlot → Vehicle
4. **Multiplicity**: 1:*, 0..1 relationships
5. **Enums**: VehicleType, VehicleStatus, SlotStatus

### ⚠️ Minor Corrections:
1. **VehicleType enum** should be: `TWO_WHEELER`, `FOUR_WHEELER`, `HEAVY_VEHICLE` (not `SUV`)
2. **ParkingService** doesn't have `parkingLot: int` or `pricing: double` fields
3. Methods like `getAvailableSlot()` and `generateSlip()` don't exist - actual methods are different

---

## 🎯 GRASP PATTERNS IN YOUR PROJECT

### 1. INFORMATION EXPERT
**"Assign responsibility to the class that has the information"**

#### 📍 Location 1: Floor Entity
```
📁 /src/main/java/com/smartparking/entity/Floor.java
📍 Lines: 42-50
```

```java
public void incrementAllottedSlots() {
    this.allottedSlots++;
}

public void decrementAllottedSlots() {
    if (this.allottedSlots > 0) {
        this.allottedSlots--;
    }
}
```

**Why**: Floor knows about its `allottedSlots` count, so it's the expert to modify it.

#### 📍 Location 2: ParkingServiceImpl - Type Mapping
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 119-125
```

```java
private SlotType mapVehicleTypeToSlotType(VehicleType vehicleType) {
    return switch (vehicleType) {
        case TWO_WHEELER -> SlotType.TWO_WHEELER;
        case FOUR_WHEELER -> SlotType.FOUR_WHEELER;
        case HEAVY_VEHICLE -> SlotType.HEAVY_VEHICLE;
    };
}
```

**Why**: ParkingService is the expert in parking business logic, so it knows how to map vehicle types.

---

### 2. CREATOR
**"Assign B to create A if B contains/aggregates A"**

#### 📍 Location 1: ParkingServiceImpl Creates Vehicle
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 55-61
```

```java
Vehicle vehicle = Vehicle.builder()
        .vehicleType(request.getVehicleType())
        .vehicleRegistration(request.getVehicleRegistration())
        .timeIn(LocalDateTime.now())
        .status(VehicleStatus.PARKED)
        .assignedSlot(availableSlot)
        .build();
```

**Why**: ParkingService manages vehicles in parking context, so it creates them.

#### 📍 Location 2: ParkingLotServiceImpl Creates ParkingSlots
```
📁 /src/main/java/com/smartparking/service/impl/ParkingLotServiceImpl.java
📍 Lines: 95-107
```

```java
for (Map.Entry<SlotType, Integer> entry : request.getSlotConfiguration().entrySet()) {
    SlotType slotType = entry.getKey();
    Integer count = entry.getValue();

    for (int i = 0; i < count; i++) {
        ParkingSlot slot = ParkingSlot.builder()
                .slotStatus(SlotStatus.AVAILABLE)
                .slotType(slotType)
                .floor(floor)
                .build();
        slots.add(slot);
    }
}
```

**Why**: ParkingLotService manages floors and slots, so it creates them.

---

### 3. CONTROLLER
**"Assign responsibility to coordinate system operations"**

#### 📍 Location: All REST Controllers
```
📁 /src/main/java/com/smartparking/controller/
   ├─ ParkingController.java        (Lines: 16-42)
   ├─ EmployeeController.java       (Lines: 16-70)
   ├─ ParkingLotController.java     (Lines: 17-89)
   ├─ AuthController.java           (Lines: 10-34)
   └─ HealthController.java         (Lines: 8-26)
```

**Example - ParkingController:**
```java
@RestController
@RequestMapping("/api/parking")
@RequiredArgsConstructor
public class ParkingController {

    private final ParkingService parkingService;

    @PostMapping("/entry")
    public ResponseEntity<ApiResponse<VehicleResponse>> parkVehicle(
            @Valid @RequestBody VehicleEntryRequest request) {
        VehicleResponse response = parkingService.parkVehicle(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Vehicle parked successfully", response));
    }
}
```

**Why**: Controllers coordinate between HTTP layer and business logic.

---

### 4. LOW COUPLING
**"Minimize dependencies between classes"**

#### 📍 Location: Service Interface Abstraction
```
📁 /src/main/java/com/smartparking/service/ParkingService.java
📍 Interface (Lines: 6-10)
```

```java
public interface ParkingService {
    VehicleResponse parkVehicle(VehicleEntryRequest request);
    VehicleResponse exitVehicle(String vehicleRegistration);
    VehicleResponse getVehicleByRegistration(String vehicleRegistration);
}
```

```
📁 /src/main/java/com/smartparking/controller/ParkingController.java
📍 Usage (Line: 18)
```

```java
private final ParkingService parkingService;  // ← Interface, not implementation
```

**Why**: Controllers depend on interfaces, not concrete classes. Implementation can change without affecting controllers.

---

### 5. HIGH COHESION
**"Keep related responsibilities together"**

#### 📍 Location: ParkingServiceImpl
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 25-140
```

**All methods related to parking:**
- `parkVehicle()` - Park a vehicle
- `exitVehicle()` - Exit and bill
- `getVehicleByRegistration()` - Get info
- `mapVehicleTypeToSlotType()` - Helper
- `mapToResponse()` - Mapping helper

**Why**: Single responsibility - all parking-related operations in one place.

---

### 6. POLYMORPHISM
**"Handle alternatives using polymorphic operations"**

#### 📍 Location: PricingStrategy
```
📁 /src/main/java/com/smartparking/service/strategy/PricingStrategy.java
📍 Lines: 7-9 (Interface)
```

```java
public interface PricingStrategy {
    double calculatePrice(VehicleType vehicleType, Duration parkingDuration);
}
```

```
📁 /src/main/java/com/smartparking/service/strategy/DefaultPricingStrategy.java
📍 Lines: 9-36 (Implementation)
```

```java
@Component
public class DefaultPricingStrategy implements PricingStrategy {
    @Override
    public double calculatePrice(VehicleType vehicleType, Duration parkingDuration) {
        // Different pricing for different vehicle types
    }
}
```

```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Line: 88 (Usage)
```

```java
double billAmount = pricingStrategy.calculatePrice(vehicle.getVehicleType(), parkingDuration);
```

**Why**: Can swap pricing algorithms without changing ParkingService code.

---

### 7. PURE FABRICATION
**"Create artificial class for design purposes"**

#### 📍 Location 1: ApiResponse
```
📁 /src/main/java/com/smartparking/dto/response/ApiResponse.java
📍 Lines: 8-32
```

```java
@Data
@Builder
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .data(null)
                .build();
    }
}
```

**Why**: Not a real-world parking concept, but provides consistent API structure.

#### 📍 Location 2: GlobalExceptionHandler
```
📁 /src/main/java/com/smartparking/exception/GlobalExceptionHandler.java
📍 Lines: 14-69
```

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiResponse<?>> handleResourceNotFoundException(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(ex.getMessage()));
    }
    // ... more handlers
}
```

**Why**: Fabricated class to centralize exception handling.

---

### 8. INDIRECTION
**"Assign responsibility to intermediate object"**

#### 📍 Location: Service Layer as Mediator
```
Controller → Service Interface → Service Implementation → Repository
```

```
📁 /src/main/java/com/smartparking/controller/ParkingController.java
📍 Lines: 18, 23
```

```java
private final ParkingService parkingService;

VehicleResponse response = parkingService.parkVehicle(request);
```

```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 29-30
```

```java
private final VehicleRepository vehicleRepository;
private final ParkingSlotRepository parkingSlotRepository;
```

**Why**: Service layer mediates between controllers and repositories, reducing coupling.

---

### 9. PROTECTED VARIATIONS
**"Create stable interfaces around variation points"**

#### 📍 Location 1: PricingStrategy Interface
```
📁 /src/main/java/com/smartparking/service/strategy/PricingStrategy.java
📍 Lines: 7-9
```

```java
public interface PricingStrategy {
    double calculatePrice(VehicleType vehicleType, Duration parkingDuration);
}
```

**Protection**: Can add new pricing strategies without changing existing code:
- WeekendPricingStrategy
- PeakHourPricingStrategy
- MemberDiscountPricingStrategy

#### 📍 Location 2: Service Interfaces
```
📁 /src/main/java/com/smartparking/service/
   ├─ ParkingService.java
   ├─ EmployeeService.java
   ├─ ParkingLotService.java
   └─ AuthService.java
```

**Protection**: Implementation details can vary without affecting clients.

---

## 🎨 GOF DESIGN PATTERNS IN YOUR PROJECT

### CREATIONAL PATTERNS

### 1. SINGLETON PATTERN ⭐
**"Ensure only one instance exists"**

#### 📍 Location: FirebaseApp Configuration
```
📁 /src/main/java/com/smartparking/config/FirebaseConfig.java
📍 Lines: 24-56
```

```java
@Bean
public FirebaseApp initializeFirebase() throws IOException {
    try {
        if (FirebaseApp.getApps().isEmpty()) {
            // Create instance
            FirebaseApp app = FirebaseApp.initializeApp(options);
            return app;
        } else {
            // Return existing instance
            return FirebaseApp.getInstance();
        }
    }
}
```

**Why Singleton**:
- Checks if instance exists: `FirebaseApp.getApps().isEmpty()`
- Reuses existing: `FirebaseApp.getInstance()`
- Creates only if needed
- Spring `@Bean` also enforces singleton scope

---

### 2. BUILDER PATTERN ⭐⭐⭐
**"Construct complex objects step by step"**

#### 📍 Location: All Entities (via Lombok @Builder)
```
📁 /src/main/java/com/smartparking/entity/
   ├─ Vehicle.java        (@Builder on line 19)
   ├─ Employee.java       (@Builder on line 20)
   ├─ ParkingLot.java     (@Builder on line 18)
   ├─ Floor.java          (@Builder on line 17)
   └─ ParkingSlot.java    (@Builder on line 16)
```

**Usage Example:**
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 55-61
```

```java
Vehicle vehicle = Vehicle.builder()
        .vehicleType(request.getVehicleType())
        .vehicleRegistration(request.getVehicleRegistration())
        .timeIn(LocalDateTime.now())
        .status(VehicleStatus.PARKED)
        .assignedSlot(availableSlot)
        .build();
```

**Benefits**:
- Fluent, readable construction
- Optional parameters
- Immutability possible
- Clear what's being set

---

### 3. FACTORY METHOD PATTERN ⭐
**"Let framework create implementations"**

#### 📍 Location: Spring Data JPA Repositories
```
📁 /src/main/java/com/smartparking/repository/
   ├─ VehicleRepository.java         (Lines: 12-16)
   ├─ EmployeeRepository.java        (Lines: 10-13)
   ├─ ParkingSlotRepository.java     (Lines: 14-23)
   ├─ FloorRepository.java           (Lines: 11-14)
   └─ ParkingLotRepository.java      (Lines: 10-12)
```

**Example:**
```java
public interface VehicleRepository extends JpaRepository<Vehicle, String> {
    Optional<Vehicle> findByVehicleRegistration(String registration);
    // Spring generates implementation at runtime!
}
```

**Why Factory Method**:
- You define interface
- Spring creates concrete class
- Implementation decided at runtime
- No manual implementation needed

---

### STRUCTURAL PATTERNS

### 4. FACADE PATTERN ⭐⭐
**"Provide simple interface to complex subsystem"**

#### 📍 Location: ParkingServiceImpl
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 34-74
```

```java
@Override
@Transactional
public VehicleResponse parkVehicle(VehicleEntryRequest request) {
    // HIDES COMPLEXITY:
    // 1. Check if vehicle already parked (repository call)
    // 2. Map vehicle type to slot type (business logic)
    // 3. Find available slot (repository query)
    // 4. Create vehicle entity (builder pattern)
    // 5. Save vehicle (repository)
    // 6. Update slot status (repository)
    // 7. Increment floor counter (entity method)
    // 8. Return response DTO (mapping)

    // Controller just calls: parkingService.parkVehicle(request)
    // Simple facade hiding 8+ complex operations!
}
```

**Benefits**:
- Simple API for complex operations
- Controller doesn't know internal complexity
- Easy to use, hard to misuse

#### 📍 Also in: ParkingLotServiceImpl.addFloor()
```
📁 /src/main/java/com/smartparking/service/impl/ParkingLotServiceImpl.java
📍 Lines: 69-114
```

**Hides**: Lot validation, floor creation, slot generation, batch saving

---

### 5. ADAPTER PATTERN ⭐
**"Convert one interface to another"**

#### 📍 Location: FirebaseAuthenticationFilter
```
📁 /src/main/java/com/smartparking/security/FirebaseAuthenticationFilter.java
📍 Lines: 21-61
```

```java
@Component
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) {
        String token = authorizationHeader.substring(7);

        // ADAPTS Firebase authentication TO Spring Security
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);

        // Convert Firebase format to Spring Security format
        UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(uid, null, new ArrayList<>());

        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}
```

**Adaptation**:
- **From**: Firebase authentication (FirebaseToken)
- **To**: Spring Security (UsernamePasswordAuthenticationToken)
- Converts incompatible interfaces

---

### 6. PROXY PATTERN ⭐
**"Control access to object"**

#### 📍 Location 1: JPA Repository Proxies
```
📁 /src/main/java/com/smartparking/repository/VehicleRepository.java
📍 Lines: 12
```

```java
public interface VehicleRepository extends JpaRepository<Vehicle, String> {
    // Spring creates PROXY implementation at runtime
    Optional<Vehicle> findByVehicleRegistration(String registration);
}
```

**Why Proxy**:
- You call: `vehicleRepository.findByVehicleRegistration()`
- Actually calls: Spring's proxy → Generated implementation → Database
- Proxy controls access and adds functionality (transactions, caching)

#### 📍 Location 2: Lazy Loading Proxies
```
📁 /src/main/java/com/smartparking/entity/Vehicle.java
📍 Lines: 48-50
```

```java
@OneToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "assigned_slot_id")
private ParkingSlot assignedSlot;  // ← Proxy until accessed
```

**Why Proxy**:
- Object not loaded immediately
- JPA creates proxy placeholder
- Real data loaded only when accessed
- Improves performance

---

### BEHAVIORAL PATTERNS

### 7. STRATEGY PATTERN ⭐⭐⭐
**"Define family of interchangeable algorithms"**

#### 📍 Complete Implementation:

**Strategy Interface:**
```
📁 /src/main/java/com/smartparking/service/strategy/PricingStrategy.java
📍 Lines: 7-9
```

```java
public interface PricingStrategy {
    double calculatePrice(VehicleType vehicleType, Duration parkingDuration);
}
```

**Concrete Strategy:**
```
📁 /src/main/java/com/smartparking/service/strategy/DefaultPricingStrategy.java
📍 Lines: 9-36
```

```java
@Component
public class DefaultPricingStrategy implements PricingStrategy {
    private static final double TWO_WHEELER_BASE_RATE = 10.0;
    private static final double FOUR_WHEELER_BASE_RATE = 20.0;
    private static final double HEAVY_VEHICLE_BASE_RATE = 40.0;

    @Override
    public double calculatePrice(VehicleType vehicleType, Duration parkingDuration) {
        double hours = parkingDuration.toMinutes() / 60.0;

        if (hours < 0.5) {
            return 5.0; // Minimum charge
        }

        double baseRate = switch (vehicleType) {
            case TWO_WHEELER -> TWO_WHEELER_BASE_RATE;
            case FOUR_WHEELER -> FOUR_WHEELER_BASE_RATE;
            case HEAVY_VEHICLE -> HEAVY_VEHICLE_BASE_RATE;
        };

        return baseRate * Math.ceil(hours);
    }
}
```

**Context (Uses Strategy):**
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Lines: 31, 88
```

```java
private final PricingStrategy pricingStrategy;

// Usage:
double billAmount = pricingStrategy.calculatePrice(
    vehicle.getVehicleType(),
    parkingDuration
);
```

**Easy to Extend:**
```java
// Future strategies (just implement interface):
@Component
public class WeekendPricingStrategy implements PricingStrategy {
    @Override
    public double calculatePrice(VehicleType type, Duration duration) {
        return defaultPrice * 0.5; // 50% off weekends
    }
}

@Component
public class PeakHourPricingStrategy implements PricingStrategy {
    @Override
    public double calculatePrice(VehicleType type, Duration duration) {
        return defaultPrice * 1.5; // Surge pricing
    }
}
```

**Benefits**:
- Swap algorithms at runtime
- Add new strategies without changing existing code
- Open/Closed Principle

---

### 8. TEMPLATE METHOD PATTERN ⭐
**"Define algorithm skeleton, let subclasses override steps"**

#### 📍 Location: JPA Entity Lifecycle Callbacks
```
📁 /src/main/java/com/smartparking/entity/Employee.java
📍 Lines: 61-70
```

```java
@PrePersist
protected void onCreate() {
    createdAt = LocalDateTime.now();
    updatedAt = LocalDateTime.now();
}

@PreUpdate
protected void onUpdate() {
    updatedAt = LocalDateTime.now();
}
```

**Template (Defined by JPA)**:
1. Validate entity
2. **@PrePersist** ← Your custom step
3. Insert into database
4. **@PostPersist** ← Your custom step

**Why Template Method**:
- JPA defines save algorithm
- You customize specific steps
- Same pattern in: Employee, ParkingLot, Vehicle entities

---

### 9. CHAIN OF RESPONSIBILITY PATTERN ⭐
**"Pass request through chain of handlers"**

#### 📍 Location 1: Exception Handler Chain
```
📁 /src/main/java/com/smartparking/exception/GlobalExceptionHandler.java
📍 Lines: 14-69
```

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)  // Handler 1
    public ResponseEntity<?> handleResourceNotFound(...) { }

    @ExceptionHandler(DuplicateResourceException.class)  // Handler 2
    public ResponseEntity<?> handleDuplicate(...) { }

    @ExceptionHandler(NoAvailableSlotException.class)  // Handler 3
    public ResponseEntity<?> handleNoSlot(...) { }

    @ExceptionHandler(Exception.class)  // Handler 4 (catch-all)
    public ResponseEntity<?> handleGeneral(...) { }
}
```

**Chain Flow**:
```
Exception thrown
    ↓
Handler 1? No → Handler 2? No → Handler 3? No → Handler 4? Yes!
```

#### 📍 Location 2: Security Filter Chain
```
📁 /src/main/java/com/smartparking/config/SecurityConfig.java
📍 Lines: 44
```

```java
.addFilterBefore(firebaseAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
```

**Chain**: Request → FirebaseFilter → UsernamePasswordFilter → ... → Controller

---

### 10. OBSERVER PATTERN (Implicit) ⭐
**"Notify dependents when state changes"**

#### 📍 Location: Spring @Transactional
```
📁 /src/main/java/com/smartparking/service/impl/ParkingServiceImpl.java
📍 Line: 35
```

```java
@Transactional
public VehicleResponse parkVehicle(...) {
    // Transaction manager OBSERVES method execution
    // On success: Commits
    // On exception: Rolls back
}
```

**Observers**:
- Transaction Manager observes method execution
- On success/failure, notifies database to commit/rollback

---

## 📊 PATTERN SUMMARY TABLE

### GRASP Patterns (9 Found)

| Pattern | Count | Key Location |
|---------|-------|-------------|
| **Information Expert** | 2+ | Floor.java, ParkingServiceImpl.java |
| **Creator** | 2+ | ParkingServiceImpl, ParkingLotServiceImpl |
| **Controller** | 5 | All *Controller.java |
| **Low Coupling** | All | Service interfaces |
| **High Cohesion** | All | Service implementations |
| **Polymorphism** | 1 | PricingStrategy |
| **Pure Fabrication** | 2 | ApiResponse, GlobalExceptionHandler |
| **Indirection** | All | Service layer |
| **Protected Variations** | 2+ | Interfaces |

### GoF Patterns (10 Found)

| Category | Pattern | Location |
|----------|---------|----------|
| **Creational** | Singleton | FirebaseConfig.java |
| | Builder | All entities (@Builder) |
| | Factory Method | All repositories |
| **Structural** | Facade | Service implementations |
| | Adapter | FirebaseAuthenticationFilter.java |
| | Proxy | JPA proxies, Lazy loading |
| **Behavioral** | Strategy | PricingStrategy + DefaultPricingStrategy |
| | Template Method | Entity @PrePersist, @PreUpdate |
| | Chain of Responsibility | GlobalExceptionHandler, SecurityFilterChain |
| | Observer | @Transactional |

---

## 🗂️ PATTERN LOCATIONS BY FOLDER

```
/src/main/java/com/smartparking/

📁 entity/                    GRASP: Information Expert, Creator
                              GoF: Builder, Template Method
   ├─ Employee.java
   ├─ Vehicle.java
   ├─ ParkingSlot.java
   ├─ Floor.java              ← incrementAllottedSlots() (Expert)
   └─ ParkingLot.java

📁 service/                   GRASP: Low Coupling, Protected Variations
                              GoF: -
   ├─ ParkingService.java     ← Interface (Protected Variations)
   ├─ EmployeeService.java
   ├─ ParkingLotService.java
   └─ AuthService.java

📁 service/impl/              GRASP: High Cohesion, Creator, Indirection
                              GoF: Facade
   ├─ ParkingServiceImpl.java ← Facade pattern
   ├─ EmployeeServiceImpl.java
   ├─ ParkingLotServiceImpl.java
   └─ AuthServiceImpl.java

📁 service/strategy/          GRASP: Polymorphism, Protected Variations
                              GoF: Strategy
   ├─ PricingStrategy.java    ← Strategy interface
   └─ DefaultPricingStrategy.java ← Concrete strategy

📁 repository/                GRASP: Indirection
                              GoF: Factory Method, Proxy
   ├─ VehicleRepository.java
   ├─ EmployeeRepository.java
   ├─ ParkingSlotRepository.java
   ├─ FloorRepository.java
   └─ ParkingLotRepository.java

📁 controller/                GRASP: Controller, Indirection
                              GoF: -
   ├─ ParkingController.java  ← Controller pattern
   ├─ EmployeeController.java
   ├─ ParkingLotController.java
   ├─ AuthController.java
   └─ HealthController.java

📁 security/                  GRASP: -
                              GoF: Adapter, Chain of Responsibility
   └─ FirebaseAuthenticationFilter.java ← Adapter

📁 config/                    GRASP: -
                              GoF: Singleton, Chain of Responsibility
   ├─ FirebaseConfig.java     ← Singleton
   └─ SecurityConfig.java     ← Chain (Filter chain)

📁 exception/                 GRASP: Pure Fabrication
                              GoF: Chain of Responsibility
   └─ GlobalExceptionHandler.java ← Chain pattern

📁 dto/                       GRASP: Pure Fabrication
                              GoF: Builder
   ├─ request/
   └─ response/
       └─ ApiResponse.java    ← Pure Fabrication + Builder
```

---

## 🎯 PATTERN INTERACTION DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                    Pattern Interaction                       │
└─────────────────────────────────────────────────────────────┘

HTTP Request
    │
    ▼
┌──────────────┐  GRASP: Controller
│ Controller   │  GoF: -
└──────┬───────┘
       │ GRASP: Indirection, Low Coupling
       ▼
┌──────────────┐  GRASP: Protected Variations
│Service (I)   │  GoF: -
└──────┬───────┘
       │ GRASP: Polymorphism
       ▼
┌──────────────┐  GRASP: High Cohesion, Creator, Information Expert
│ServiceImpl   │  GoF: Facade, Strategy (uses PricingStrategy)
└──────┬───────┘
       │ GRASP: Indirection
       ▼
┌──────────────┐  GRASP: -
│ Repository   │  GoF: Factory Method, Proxy
└──────┬───────┘
       │
       ▼
┌──────────────┐  GRASP: Information Expert
│   Entity     │  GoF: Builder, Template Method
└──────────────┘
```

---

## ✅ DESIGN QUALITY METRICS

Your codebase demonstrates:

1. **Solid GRASP Principles**: All 9 patterns present
2. **10 GoF Patterns**: Well-distributed across all categories
3. **Low Coupling**: Through interfaces and dependency injection
4. **High Cohesion**: Each class has single, clear purpose
5. **Open/Closed Principle**: Strategy pattern allows extension
6. **Dependency Inversion**: Depends on abstractions, not concretions

---

## 🚀 EXTENSIBILITY EXAMPLES

### Easy to Add (Thanks to Patterns):

1. **New Pricing Strategy**:
   ```java
   @Component
   public class MembershipPricingStrategy implements PricingStrategy {
       // 20% discount for members
   }
   ```
   No changes to ParkingService needed!

2. **New Vehicle Type**:
   Add to enum → Update mapVehicleTypeToSlotType() → Done!

3. **New Exception Type**:
   Add handler method in GlobalExceptionHandler → Done!

4. **New Entity**:
   Create entity + repository interface → Spring generates implementation!

---

## END OF ANALYSIS

Your codebase is a **textbook example** of good design patterns usage! 🎉