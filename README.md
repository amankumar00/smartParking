# Smart Parking Backend System

A comprehensive backend system for managing parking lot operations built with Java Spring Boot.

## Features

- **Multi-floor Parking Management**: Support for parking lots with multiple floors
- **Slot Type Management**: Three types of parking slots (Two Wheeler, Four Wheeler, Heavy Vehicle)
- **Dynamic Pricing**: Flexible pricing strategy based on vehicle type and parking duration
- **Employee Management**: CRUD operations for managing parking lot staff
- **Real-time Slot Tracking**: Monitor available and occupied slots in real-time
- **Billing System**: Automatic bill generation on vehicle exit

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
  - Spring Data JPA
  - Spring Web
  - Spring Security
  - Spring Validation
- **Firebase Admin SDK** (Authentication)
- **H2 Database** (Development)
- **PostgreSQL** (Production)
- **MySQL** (Production - Alternative)
- **Docker** (Containerization)
- **Lombok**
- **Maven**

## Project Structure

```
smartParkingBackend/
├── src/
│   ├── main/
│   │   ├── java/com/smartparking/
│   │   │   ├── entity/          # JPA Entities
│   │   │   ├── repository/      # Data Access Layer
│   │   │   ├── service/         # Business Logic Layer
│   │   │   │   ├── impl/
│   │   │   │   └── strategy/    # Pricing strategies
│   │   │   ├── controller/      # REST Controllers
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   │   ├── request/
│   │   │   │   └── response/
│   │   │   ├── exception/       # Custom Exceptions
│   │   │   ├── enums/           # Enumerations
│   │   │   └── SmartParkingApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── application-prod.properties
│   └── test/
├── pom.xml
└── README.md
```

## Getting Started

### Prerequisites

**Option 1: Docker (Recommended)**
- Docker Desktop installed ([Get Docker](https://www.docker.com/products/docker-desktop))
- No need for Java, Maven, or PostgreSQL!

**Option 2: Manual Setup**
- Java 17 or higher
- Maven 3.6+
- PostgreSQL 15+ or MySQL 8.0+ (for production)

### Quick Start with Docker

**1. Start everything with one command:**
```bash
docker-compose up -d
```

This will automatically:
- Start PostgreSQL database
- Build and start the Spring Boot application
- Set up networking between containers

**2. Test the application:**
```bash
curl http://localhost:8080/api/health
```

**3. View logs:**
```bash
docker-compose logs -f app
```

**4. Stop everything:**
```bash
docker-compose down
```

📖 **See [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) for complete Docker guide**

### Manual Installation (Without Docker)

1. Clone the repository
```bash
git clone <repository-url>
cd smartParkingBackend
```

2. Build the project
```bash
mvn clean install
```

3. Run the application (Development mode with H2)
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### H2 Console (Development Database)

Access H2 database console at: `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:file:./data/smartparking`
- Username: `sa`
- Password: (leave empty)

**Note**: The database is file-based and persists between restarts. Database files are stored in the `data/` directory.

### Production Setup

1. Update database credentials in `application-prod.properties` or `application-render.properties`
2. Create database:
```sql
CREATE DATABASE smartparking;
```
3. Run with production profile:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

## API Endpoints

### Parking Operations

#### Park Vehicle
```http
POST /api/parking/entry
Content-Type: application/json

{
  "vehicleType": "FOUR_WHEELER",
  "vehicleRegistration": "KA01AB1234"
}
```

#### Exit Vehicle
```http
POST /api/parking/exit/{vehicleRegistration}
```

#### Get Vehicle Information
```http
GET /api/parking/vehicle/{vehicleRegistration}
```

### Parking Lot Management

#### Create Parking Lot
```http
POST /api/parking-lots
Content-Type: application/json

{
  "name": "City Center Parking",
  "address": "123 Main Street",
  "totalFloors": 5
}
```

#### Get All Parking Lots
```http
GET /api/parking-lots
```

#### Get Parking Lot by ID
```http
GET /api/parking-lots/{parkingLotId}
```

#### Add Floor to Parking Lot
```http
POST /api/parking-lots/floors
Content-Type: application/json

{
  "floorNo": 1,
  "parkingLotId": "lot-uuid",
  "slotConfiguration": {
    "TWO_WHEELER": 50,
    "FOUR_WHEELER": 30,
    "HEAVY_VEHICLE": 10
  }
}
```

#### Get Floors by Parking Lot
```http
GET /api/parking-lots/{parkingLotId}/floors
```

### Employee Management

#### Create Employee
```http
POST /api/employees
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phNo": "+1234567890",
  "dob": "1990-01-01",
  "gender": "MALE",
  "address": "123 Street",
  "roles": "OPERATOR"
}
```

#### Get All Employees
```http
GET /api/employees
```

#### Get Employee by ID
```http
GET /api/employees/{empId}
```

#### Get Employee by Email
```http
GET /api/employees/email/{email}
```

#### Update Employee
```http
PUT /api/employees/{empId}
Content-Type: application/json

{
  "name": "John Doe Updated",
  "email": "john.doe@example.com",
  ...
}
```

#### Delete Employee
```http
DELETE /api/employees/{empId}
```

## Pricing Strategy

The default pricing strategy:
- **Two Wheeler**: ₹10/hour
- **Four Wheeler**: ₹20/hour
- **Heavy Vehicle**: ₹40/hour
- **Minimum Charge**: ₹5 (for parking less than 30 minutes)

Pricing is calculated based on:
- Vehicle type
- Parking duration (rounded up to the nearest hour)

## Database Schema

### Main Entities
- **Employee**: Staff management
- **ParkingLot**: Main parking lot details
- **Floor**: Individual floors in parking lot
- **ParkingSlot**: Individual parking slots
- **Vehicle**: Vehicle tracking and billing

### Relationships
- ParkingLot → Floor (One-to-Many)
- Floor → ParkingSlot (One-to-Many)
- ParkingSlot → Vehicle (One-to-One)

## Exception Handling

The application includes comprehensive exception handling:
- `ResourceNotFoundException`: Entity not found
- `DuplicateResourceException`: Duplicate entity creation
- `NoAvailableSlotException`: No parking slots available
- `InvalidOperationException`: Invalid business operation
- Validation exceptions with field-level error messages

## Extensibility

The system is designed for easy extension:

1. **Add New Vehicle Types**:
   - Add enum values in `VehicleType` and `SlotType`
   - Update pricing strategy

2. **Custom Pricing Strategies**:
   - Implement `PricingStrategy` interface
   - Configure in service layer

3. **Additional Features**:
   - Reservation system
   - Payment gateway integration
   - Mobile app integration
   - Analytics and reporting

## Deployment

### Deploy to Render (Free Hosting)

This application is ready to deploy to [Render](https://render.com) using Docker.

**Quick Deploy:**
1. Push code to GitHub/GitLab
2. Create PostgreSQL database on Render
3. Create Web Service with Docker runtime
4. Set environment variables
5. Deploy!

📖 **Complete guides:**
- [DOCKER_DEPLOYMENT_GUIDE.md](DOCKER_DEPLOYMENT_GUIDE.md) - Full Docker deployment guide
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step deployment checklist
- [RENDER_DEPLOYMENT_GUIDE.md](RENDER_DEPLOYMENT_GUIDE.md) - Original Render guide (non-Docker)

**Deployment Features:**
- 🐳 Dockerized for consistent deployment
- 🔄 Auto-deploy on git push
- 🆓 Free tier available (512 MB RAM, PostgreSQL 1GB)
- 🔒 HTTPS enabled automatically
- 📊 Built-in monitoring and logs

### Other Deployment Options

The Docker setup works with:
- **AWS ECS/Fargate**
- **Google Cloud Run**
- **Azure Container Instances**
- **Heroku**
- **DigitalOcean App Platform**

See [DOCKER_DEPLOYMENT_GUIDE.md](DOCKER_DEPLOYMENT_GUIDE.md) for platform-specific instructions.

## Documentation

- [HOW_TO_RUN.md](HOW_TO_RUN.md) - Complete guide to run locally
- [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) - Quick Docker setup (5 minutes)
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Firebase authentication setup
- [UML_CLASS_DIAGRAM_REFERENCE.md](UML_CLASS_DIAGRAM_REFERENCE.md) - All classes for UML diagrams
- [USE_CASE_DIAGRAM_REFERENCE.md](USE_CASE_DIAGRAM_REFERENCE.md) - All use cases

## Future Enhancements

- Slot reservation system
- Multiple parking lot support
- Advanced reporting and analytics
- Payment gateway integration
- QR code-based vehicle entry/exit
- Mobile application
- Email/SMS notifications
- Security camera integration

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is open source and available under the MIT License.

## Contact

For any queries or support, please contact the development team.
